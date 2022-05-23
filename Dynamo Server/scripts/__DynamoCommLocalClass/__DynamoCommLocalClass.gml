#macro __DYNAMO_COMM_TRACE_MESSAGE       if (__DYNAMO_COMM_VERBOSE_RECEIVE) __DynamoTrace("Received message from \"", _deviceIdent, "\" to \"", _deviceDestination, "\" said ", _parametersArray);
#macro __DYNAMO_CLIENT_ONLY              if (__serverMode) return;
#macro __DYNAMO_SERVER_ONLY              if (!__serverMode) return;
#macro __DYNAMO_IDENT_MATCHES_US_OR_ALL  if ((_deviceDestination != __ident) && (_deviceDestination != "all")) return;
#macro __DYNAMO_IDENT_MATCHES_US         if (_deviceDestination != __ident) return;

        
function __DynamoCommLocalClass(_serverMode, _ident = undefined) constructor
{
    __serverMode = _serverMode;
    if (__serverMode)
    {
        __DynamoTrace("Created new local server handler");
    }
    else
    {
        __DynamoTrace("Created new local client handler");
    }
    
    __alive = true;
    
    __socket = -1;
    __ident = _ident;
    if (__ident == undefined)
    {
        __ident = __DynamoGenerateIdent();
        __DynamoTrace("Chose new random ident \"", __ident, "\"");
    }
    else
    {
        __DynamoTrace("Using ident \"", __ident, "\"");
    }
    
    __defaultDestination = "all";
    
    __announceLocalTime  = -infinity;
    __messageReceiveTime = -infinity;
    __messageSendTime    = -infinity;
    __warningTime        = -infinity;
    
    __firstConnectionTimeElapsed = 0; //Counts up in __EndStep()
    __clientHasFoundServer       = false;
    
    __refreshRequested = false;
    __refreshCallback  = undefined; //Only used on the client
    __refreshToken     = undefined;
    
    __downloadArray = [];
    __uploadArray   = [];
    
    
    
    if (__serverMode)
    {
        __port = global.__dynamoCommServerPort;
        __DynamoTrace("Port = ", __port);
        
        //Ensure we have a Dynamo Server temp directory available for use
        directory_create(global.__dynamoCommServerTempDirectory);
        __DynamoTrace("Server temporary directory = ", global.__dynamoCommServerTempDirectory);
        
        __socket = network_create_server_raw(network_socket_udp, __port, 100);
        __DynamoTrace("Opened a new socket ", __socket, " on port ", __port);
        
        if (__socket < 0)
        {
            __DynamoTrace("Warning! Failed to open server socket");
            __Destroy();
            return;
        }
        
        __DynamoTrace("Local server successfully started");
    }
    else
    {
        __port = global.__dynamoCommClientPort;
        __DynamoTrace("Port = ", __port);
        
        __socket = network_create_server_raw(network_socket_udp, __port, 100);
        __DynamoTrace("Opened a new socket ", __socket, " on port ", __port);
        
        if (__socket < 0)
        {
            __DynamoTrace("Warning! Failed to open client socket");
            __Destroy();
            return;
        }
        
        __DynamoTrace("Local client successfully started");
    }
    
    
    
    static __Destroy = function()
    {
        if (!__alive) return;
        
        __alive = false;
        
        if (__socket > 0)
        {
            __DynamoTrace("Destroying socket ", __socket);
            network_destroy(__socket);
        }
    }
    
    static __EndStep = function()
    {
        if (!__alive) return;
        
        if (current_time - __announceLocalTime > 2000)
        {
            __announceLocalTime = current_time;
            
            if (__serverMode)
            {
                __Send(["IAmServer"]);
            }
            else
            {
                __Send(["IAmClient", global.__dynamoCommExpectedServerIdent]);
            }
        }
        
        if (!__serverMode && !__clientHasFoundServer)
        {
            //Only count the time this function is actually being executed
            //This prevents really long load times from causing Dynamo to erroneously report errors
            __firstConnectionTimeElapsed += delta_time/1000;
            
            if (__firstConnectionTimeElapsed > 15000)
            {
                __DynamoError("Failed to connect to Dynamo server (expected ident = \"", global.__dynamoCommExpectedServerIdent, "\")");
            }
        }
        
        var _i = 0;
        repeat(array_length(__downloadArray))
        {
            __downloadArray[_i].__EndStep();
            ++_i;
        }
        
        var _i = 0;
        repeat(array_length(__uploadArray))
        {
            __uploadArray[_i].__EndStep();
            ++_i;
        }
    }
    
    static __Draw = function(_x, _y)
    {
        if (!__alive) return;
        
        matrix_stack_push(matrix_build(_x, _y, 0,    0, 0, 0,    1, 1, 1));
        matrix_set(matrix_world, matrix_stack_top());
        
        var _oldFont = draw_get_font();
        draw_set_font(__DynamoDebugFont);
        
        draw_text(0, 0, self);
        if (current_time - __messageSendTime    <  500) draw_text( 200, 0, "Send"    );
        if (current_time - __messageReceiveTime <  500) draw_text( 250, 0, "Receive" );
        if (current_time - __warningTime        < 1000) draw_text( 300, 0, "Warning!");
        
        draw_set_font(_oldFont);
        
        matrix_stack_pop();
        matrix_set(matrix_world, matrix_stack_top());
    }
    
    static toString = function()
    {
        return (__serverMode? "Local server " : "Local client ") + __ident;
    }
    
    static __AsyncNetworking = function()
    {
        if (!__alive) return;
        
        //Ignore anything that's not data
        if (async_load[? "type"] != 3) exit;
        
        __messageReceiveTime = current_time;
        
        var _buffer = async_load[? "buffer"];
        if (_buffer == undefined)
        {
            __DynamoTrace("Warning! Networking data received without a buffer");
            __warningTime = current_time;
            return;
        }
        
        var _callback          = undefined;
        var _deviceIdent       = undefined;
        var _deviceDestination = undefined;
        var _parameterCount    = 0;
        var _parametersArray   = [];
        var _suffixSize        = 0;
        
        try
        {
            var _dynamoHeader = buffer_read(_buffer, buffer_string);
            if (_dynamoHeader != "Dynamo") throw "UDP packet did not include \"Dynamo\" header";
            
            _deviceIdent       = buffer_read(_buffer, buffer_string);
            _deviceDestination = buffer_read(_buffer, buffer_string);
            _parameterCount    = buffer_read(_buffer, buffer_u64   );
            _parametersArray   = array_create(max(1, _parameterCount), undefined);
            
            var _i = 0;
            repeat(_parameterCount)
            {
                _parametersArray[@ _i] = buffer_read(_buffer, buffer_string);
                ++_i;
            }
            
            _suffixSize = buffer_read(_buffer, buffer_u64);
            
            if (__serverMode)
            {
                if (variable_struct_exists(global.__dynamoCommServerAliases, _deviceDestination))
                {
                    _deviceDestination = __ident;
                }
            }
            
            var _verifyDeviceIdent = true;
            
            switch(_parametersArray[0])
            {
                //Handshakes
                case "ServerDuplicate": _callback = __ReceiveServerDuplicate; _verifyDeviceIdent = false; break;
                case "IAmClient":       _callback = __ReceiveIAmClient;       _verifyDeviceIdent = false; break;
                case "IAmServer":       _callback = __ReceiveIAmServer;       _verifyDeviceIdent = false; break;
                case "IAmYourServer":   _callback = __ReceiveIAmYourServer;   _verifyDeviceIdent = false; break;
                
                //Client -> Server commands
                case "RefreshRequest":  _callback = __ReceiveRefreshRequest;  break;
                case "RefreshCancel":   _callback = __ReceiveRefreshCancel;   break;
                case "DownloadRequest": _callback = __ReceiveDownloadRequest; break;
                case "DownloadCancel":  _callback = __ReceiveDownloadCancel;  break;
                case "UploadPacket":    _callback = __ReceiveUploadPacket;    break;
                
                //Server -> Client commands
                case "RefreshResult":  _callback = __ReceiveRefreshResult;  break;
                case "DownloadPacket": _callback = __ReceiveDownloadPacket; break;
                case "UploadCancel":   _callback = __ReceiveUploadCancel;   break;
                
                default:
                    throw "Command " + string(_parametersArray[0]) + " not supported";
                break;
            }
            
            if (_verifyDeviceIdent)
            {
                if (variable_struct_exists(global.__dynamoCommRemoteDictionary, _deviceIdent))
                {
                    throw "Ident \"" + string(_deviceIdent) + "\" not recognised (waiting for either \"IAmClient\" or \"IAmServer\" message)";
                }
            }
            
            _callback(_deviceIdent, _deviceDestination, _parametersArray, _buffer, _suffixSize);
            global.__dynamoCommRemoteDictionary[$ _deviceIdent].__lastReceive = current_time;
        }
        catch(_error)
        {
            __DynamoTrace("Warning! Error encountered whilst decoding buffer follows");
            __DynamoTrace(_error);
            __warningTime = current_time;
            return;
        }
    }
    
    
    
    #region Handshakes
    
    static __ReceiveServerDuplicate = function(_deviceIdent, _deviceDestination, _parametersArray)
    {
        __DYNAMO_COMM_TRACE_MESSAGE
        __DYNAMO_SERVER_ONLY
        
        __DynamoTrace("A duplicate server instance was created, adding \"", _deviceIdent, "\" as an alias");
        global.__dynamoCommServerAliases[$ _deviceIdent] = current_time;
    }
    
    static __ReceiveIAmClient = function(_deviceIdent, _deviceDestination, _parametersArray)
    {
        __DYNAMO_COMM_TRACE_MESSAGE
        __DYNAMO_SERVER_ONLY
        __DYNAMO_IDENT_MATCHES_US_OR_ALL
        
        __DynamoCommEnsureRemote(false, _deviceIdent);
        
        //Sebd a response
        __Send(["IAmYourServer"], _deviceIdent);
    }
    
    static __ReceiveIAmServer = function(_deviceIdent, _deviceDestination, _parametersArray)
    {
        __DYNAMO_COMM_TRACE_MESSAGE
        __DYNAMO_CLIENT_ONLY
        __DYNAMO_IDENT_MATCHES_US_OR_ALL
        
        __DynamoCommEnsureRemote(true, _deviceIdent);
    }
    
    static __ReceiveIAmYourServer = function(_deviceIdent, _deviceDestination, _parametersArray)
    {
        __DYNAMO_COMM_TRACE_MESSAGE
        __DYNAMO_CLIENT_ONLY
        __DYNAMO_IDENT_MATCHES_US
        
        if (__clientHasFoundServer) return;
        __clientHasFoundServer = true;
        
        if (global.__dynamoCommExpectedServerIdent != _deviceIdent)
        {
            global.__dynamoCommExpectedServerIdent = _deviceIdent;
            __DynamoTrace("Changing server ident to \"", global.__dynamoCommExpectedServerIdent, "\"");
        }
        else
        {
            __DynamoTrace("Found server with ident \"", global.__dynamoCommExpectedServerIdent, "\"");
        }
        
        __DynamoCommEnsureRemote(true, _deviceIdent);
    }
    
    #endregion
    
    
    
    #region Client -> Server Commands
    
    static __ReceiveRefreshRequest = function(_deviceIdent, _deviceDestination, _parametersArray)
    {
        __DYNAMO_COMM_TRACE_MESSAGE
        __DYNAMO_SERVER_ONLY
        __DYNAMO_IDENT_MATCHES_US
        
        var _token = _parametersArray[0];
        __DynamoTrace("Refresh requested (token=", _token, ")");
        
        //TODO - Perform file scan
    }
    
    static __ReceiveRefreshCancel = function(_deviceIdent, _deviceDestination, _parametersArray)
    {
        __DYNAMO_COMM_TRACE_MESSAGE
        __DYNAMO_SERVER_ONLY
        __DYNAMO_IDENT_MATCHES_US
        
        var _token = _parametersArray[0];
        __DynamoTrace("Refresh cancelled (token=", _token, ")");
        
        //TODO - Cancel file scan
    }
    
    static __ReceiveDownloadRequest = function(_deviceIdent, _deviceDestination, _parametersArray)
    {
        __DYNAMO_COMM_TRACE_MESSAGE
        __DYNAMO_SERVER_ONLY
        __DYNAMO_IDENT_MATCHES_US
        
        var _filename = _parametersArray[0];
        var _token    = _parametersArray[1];
        __DynamoTrace("Download requested for \"", _filename, "\" (token=", _token, ")");
        
        //Check this filename hasn't been requested by this device already and is in progress
        var _i = 0;
        repeat(array_length(__downloadArray))
        {
            var _downloadHandler = __downloadArray[_i];
            if ((_downloadHandler.__filename == _filename) && (_downloadHandler.__deviceIdent == _deviceIdent))
            {
                __DynamoError("Device \"", _deviceIdent, "\" is already downloading \"", _filename, "\" (token=", _downloadHandler.__token, ")");
            }
            
            ++_i;
        }
        
        array_push(__downloadArray, new __DynamoClassCommServerDownload(self, _filename, _token, _deviceIdent));
    }
    
    static __ReceiveDownloadCancel = function(_deviceIdent, _deviceDestination, _parametersArray)
    {
        __DYNAMO_COMM_TRACE_MESSAGE
        __DYNAMO_SERVER_ONLY
        __DYNAMO_IDENT_MATCHES_US
        
        var _token = _parametersArray[0];
        __DynamoTrace("Download cancelled (token=", _token, ")");
        
        //Find the matching download handler and destroy it
        var _i = 0;
        repeat(array_length(__downloadArray))
        {
            if (__downloadArray[_i].__token == _token)
            {
                __downloadArray[_i].__Destroy();
                array_delete(__downloadArray, _i, 1);
            }
            else
            {
                ++_i;
            }
        }
    }
    
    static __ReceiveUploadPacket = function(_deviceIdent, _deviceDestination, _parametersArray, _buffer, _suffixSize)
    {
        __DYNAMO_COMM_TRACE_MESSAGE
        __DYNAMO_SERVER_ONLY
        __DYNAMO_IDENT_MATCHES_US
        
        var _filename    = _parametersArray[0];
        var _token       = _parametersArray[1];
        var _totalSize   = real(_parametersArray[2]);
        var _packetIndex = real(_parametersArray[3]);
        var _packetCount = real(_parametersArray[4]);
        
        __DynamoTrace("Upload packet received for \"", _filename, "\" (token=", _token, ", packet size=", _suffixSize, ", total size=", _token, ", index=", _packetIndex, ", count=", _packetCount, ")");
        
        //Find the existing download handler with this tag
        var _found = undefined;
        var _i = 0;
        repeat(array_length(__uploadArray))
        {
            if (__uploadArray[_i].__token == _token)
            {
                _found = __uploadArray[_i];
                break;
            }
            
            ++_i;
        }
        
        //If we have no upload handler then create a new one
        if (_found == undefined)
        {
            _found = new __DynamoClassCommServerUpload(self, _token, _filename, _totalSize, _packetCount);
            array_push(__uploadArray, _found);
        }
        
        //Pass the data into the download handler
        _found.__ReceivePacket(_buffer, buffer_tell(_buffer), _suffixSize, _filename, _totalSize, _packetIndex, _packetCount);
    }
    
    #endregion
    
    
    
    #region Server -> Client Commands
    
    static __ReceiveRefreshResult = function(_deviceIdent, _deviceDestination, _parametersArray, _buffer)
    {
        __DYNAMO_COMM_TRACE_MESSAGE
        __DYNAMO_SERVER_ONLY
        __DYNAMO_IDENT_MATCHES_US
        
        var _count = 0.5*array_length(_parametersArray);
        if (_count != floor(_count)) throw "Parameter array did not have an even number of entries";
        
        __DynamoTrace("Refresh result received for ", _count, " files");
        
        var _struct = {};
        
        var _i = 0;
        repeat(_count/2)
        {
            _struct[$ _parametersArray[_i]] = _parametersArray[_i+1];
            _i += 2;
        }
        
        //TODO - Callback here
    }
    
    static __ReceiveDownloadPacket = function(_deviceIdent, _deviceDestination, _parametersArray, _buffer, _suffixSize)
    {
        __DYNAMO_COMM_TRACE_MESSAGE
        __DYNAMO_SERVER_ONLY
        __DYNAMO_IDENT_MATCHES_US
        
        var _token       = _parametersArray[0];
        var _totalSize   = real(_parametersArray[1]);
        var _packetIndex = real(_parametersArray[2]);
        var _packetCount = real(_parametersArray[3]);
        
        __DynamoTrace("Download packet received (token=", _token, ", packet size=", _suffixSize, ", total size=", _token, ", index=", _packetIndex, ", count=", _packetCount, ")");
        
        //Find the existing download handler with this tag
        var _found = undefined;
        var _i = 0;
        repeat(array_length(__downloadArray))
        {
            if (__downloadArray[_i].__token == _token)
            {
                _found = __downloadArray[_i];
                break;
            }
            
            ++_i;
        }
        
        //If we have no download handler report this as an error
        if (_found == undefined) __DynamoError("Could not find downloader handler (token=", _token, ")");
        
        //Pass the data into the download handler
        _found.__ReceivePacket(_buffer, buffer_tell(_buffer), _suffixSize, _totalSize, _packetIndex, _packetCount);
    }
    
    static __ReceiveUploadCancel = function(_deviceIdent, _deviceDestination, _parametersArray)
    {
        __DYNAMO_COMM_TRACE_MESSAGE
        __DYNAMO_SERVER_ONLY
        __DYNAMO_IDENT_MATCHES_US
        
        var _token = _parametersArray[0];
        __DynamoTrace("Upload cancelled for (token=". _token, ")");
        
        //Find the matching upload handler and destroy it
        var _i = 0;
        repeat(array_length(__uploadArray))
        {
            if (__uploadArray[_i].__token == _token)
            {
                __uploadArray[_i].__Destroy();
                array_delete(__uploadArray, _i, 1);
            }
            else
            {
                ++_i;
            }
        }
    }
    
    #endregion
    
    
    
    #region Sender Methods
    
    static __SendFormatBuffer = function(_parametersArray, _deviceDestination = __defaultDestination, _suffixBuffer = undefined, _suffixSize = undefined)
    {
        var _buffer = buffer_create(1024, buffer_grow, 1);
        buffer_write(_buffer, buffer_string, "Dynamo");
        buffer_write(_buffer, buffer_string, __ident);
        buffer_write(_buffer, buffer_string, _deviceDestination);
        buffer_write(_buffer, buffer_u64, array_length(_parametersArray));
        
        var _i = 0;
        repeat(array_length(_parametersArray))
        {
            buffer_write(_buffer, buffer_string, string(_parametersArray[_i]));
            ++_i;
        }
        
        if (_suffixBuffer != undefined)
        {
            buffer_write(_buffer, buffer_u64, _suffixSize);
            
            if (buffer_tell(_buffer) + _suffixSize < buffer_get_size(_buffer))
            {
                buffer_resize(_buffer, buffer_tell(_buffer) + _suffixSize);
            }
            
            buffer_copy(_suffixBuffer, 0, _suffixSize, _buffer, buffer_tell(_buffer));
            buffer_seek(_buffer, buffer_seek_relative, _suffixSize);
        }
        else
        {
            buffer_write(_buffer, buffer_u64, 0x00);
        }
        
        return _buffer;
    }
    
    static __Send = function(_parametersArray, _deviceDestination = __defaultDestination, _suffixBuffer = undefined, _suffixSize = undefined)
    {
        var _buffer = __SendFormatBuffer(_parametersArray, _deviceDestination, _suffixBuffer, _suffixSize);
        network_send_broadcast(__socket, __serverMode? global.__dynamoCommClientPort : global.__dynamoCommServerPort, _buffer, buffer_tell(_buffer));
        buffer_delete(_buffer);
        
        if (__DYNAMO_COMM_VERBOSE_SEND) __DynamoTrace("Broadcast message to \"", _deviceDestination, "\" saying ", _parametersArray);
        __messageSendTime = current_time;
    }
    
    static __SendDirect = function(_ip, _parametersArray, _suffixBuffer = undefined, _suffixSize = undefined)
    {
        var _buffer = __SendFormatBuffer(_parametersArray, "all", _suffixBuffer, _suffixSize);
        network_send_udp_raw(__socket, _ip, __serverMode? global.__dynamoCommClientPort : global.__dynamoCommServerPort, _buffer, buffer_tell(_buffer));
        buffer_delete(_buffer);
        
        if (__DYNAMO_COMM_VERBOSE_SEND) __DynamoTrace("Sent message to specific IP \"", _ip, "\" saying ", _parametersArray);
        __messageSendTime = current_time;
    }
    
    #endregion
}
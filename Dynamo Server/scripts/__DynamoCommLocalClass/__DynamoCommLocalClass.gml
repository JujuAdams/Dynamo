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
    
    
    
    if (!__DYNAMO_DEV_MODE)
    {
        __Destroy();
    }
    else if (__serverMode)
    {
        __port = global.__dynamoCommServerPort;
        __DynamoTrace("Port = ", __port);
        
        //Ensure we have a Dynamo Server temp directory available for use
        directory_create(global.__dynamoCommServerTempDirectory);
        __DynamoTrace("Server temporary directory = ", global.__dynamoCommServerTempDirectory);
        
        __socket = network_create_socket_ext(network_socket_udp, __port);
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
        
        __socket = network_create_socket_ext(network_socket_udp, __port);
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
        
        __alive = true;
        
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
                __Send(["IAmClient"]);
            }
        }
        
        if (!__serverMode && !__clientHasFoundServer)
        {
            //Only count the time this function is actually being executed
            //This prevents really long load times from causing Dynamo to erroneously report errors
            __firstConnectionTimeElapsed += delta_time/1000;
            
            if (__firstConnectionTimeElapsed > 15000)
            {
                if (__DYNAMO_ALLOW_NONMATCHING_SERVER)
                {
                    __DynamoError("Failed to connect to a Dynamo server");
                }
                else
                {
                    __DynamoError("Failed to connect to Dynamo server with ident of \"", global.__dynamoCommExpectedServerIdent, "\"");
                }
            }
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
        if (current_time - __messageSendTime    <  500) draw_text(   0, 10, "Send"    );
        if (current_time - __messageReceiveTime <  500) draw_text(  50, 10, "Receive" );
        if (current_time - __warningTime        < 1000) draw_text( 100, 10, "Warning!");
        
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
        
        var _deviceIdent       = undefined;
        var _deviceDestination = undefined;
        var _parameterCount    = 0;
        var _parametersArray   = [];
        
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
            
            if (__serverMode)
            {
                if (variable_struct_exists(global.__dynamoCommServerAliases, _deviceDestination))
                {
                    _deviceDestination = __ident;
                }
            }
            
            var _verifyDeviceIdent = true;
            var _callback = undefined;
            
            switch(_parametersArray[0])
            {
                case "ServerDuplicate": _callback = __ReceiveServerDuplicate; _verifyDeviceIdent = false; break;
                case "IAmClient":       _callback = __ReceiveIAmClient;       _verifyDeviceIdent = false; break;
                case "IAmServer":       _callback = __ReceiveIAmServer;       _verifyDeviceIdent = false; break;
                
                default:
                    throw "Command " + string(_parametersArray[0]) + " not supported";
                break;
            }
            
            if (!__serverMode)
            {
                if (!__DYNAMO_ALLOW_NONMATCHING_SERVER && (_deviceIdent != global.__dynamoCommExpectedServerIdent))
                {
                    if (!__clientHasFoundServer)
                    {
                        throw "Ident \"" + string(_deviceIdent) + "\" doesn't match expected server ident (" + global.__dynamoCommExpectedServerIdent + ")";
                    }
                    else
                    {
                        return;
                    }
                }
                else if (!__clientHasFoundServer && (_deviceIdent == global.__dynamoCommExpectedServerIdent))
                {
                    __clientHasFoundServer = true;
                    __DynamoTrace("Found server with ident \"", global.__dynamoCommExpectedServerIdent, "\"");
                }
            }
            
            if (_verifyDeviceIdent)
            {
                if (variable_struct_exists(global.__dynamoCommRemoteDictionary, _deviceIdent))
                {
                    throw "Ident \"" + string(_deviceIdent) + "\" not recognised (waiting for either \"IAmClient\" or \"IAmServer\" message)";
                }
            }
            
            _callback(_deviceIdent, _deviceDestination, _parametersArray, _buffer);
            
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
    
    static __ReceiveServerDuplicate = function(_deviceIdent, _deviceDestination, _parametersArray)
    {
        if (__serverMode || __DYNAMO_COMM_VERBOSE_RECEIVE)
        {
            __DynamoTrace("Received message from \"", _deviceIdent, "\" to \"", _deviceDestination, "\" said ", _parametersArray);
        }
        
        __DynamoTrace("A duplicate server instance was created");
    }
    
    static __ReceiveIAmClient = function(_deviceIdent, _deviceDestination, _parametersArray)
    {
        if (__serverMode || __DYNAMO_COMM_VERBOSE_RECEIVE)
        {
            __DynamoTrace("Received message from \"", _deviceIdent, "\" to \"", _deviceDestination, "\" said ", _parametersArray);
        }
        
        if (__serverMode && ((_deviceDestination == __ident) || (_deviceDestination == "all")))
        {
            if (!variable_struct_exists(global.__dynamoCommRemoteDictionary, _deviceIdent))
            {
                global.__dynamoCommRemoteDictionary[$ _deviceIdent] = new __DynamoCommRemoteClass(false, _deviceIdent);
                array_push(global.__dynamoCommRemoteArray, _deviceIdent);
            }
        }
    }
    
    static __ReceiveIAmServer = function(_deviceIdent, _deviceDestination, _parametersArray)
    {
        if (__serverMode || __DYNAMO_COMM_VERBOSE_RECEIVE)
        {
            __DynamoTrace("Received message from \"", _deviceIdent, "\" to \"", _deviceDestination, "\" said ", _parametersArray);
        }
        
        if (!__serverMode && ((_deviceDestination == __ident) || (_deviceDestination == "all")))
        {
            if (!variable_struct_exists(global.__dynamoCommRemoteDictionary, _deviceIdent))
            {
                global.__dynamoCommRemoteDictionary[$ _deviceIdent] = new __DynamoCommRemoteClass(true, _deviceIdent);
                array_push(global.__dynamoCommRemoteArray, _deviceIdent);
            }
        }
    }
    
    static __Send = function(_parametersArray, _deviceDestination = __defaultDestination, _suffixBuffer = undefined, _suffixSize = undefined)
    {
        var _buffer = buffer_create(1024, buffer_grow, 1);
        buffer_write(_buffer, buffer_string, "Dynamo");
        buffer_write(_buffer, buffer_string, __ident);
        buffer_write(_buffer, buffer_string, _deviceDestination);
        buffer_write(_buffer, buffer_u64, array_length(_parametersArray));
        
        if (__DYNAMO_COMM_VERBOSE_SEND)
        {
            __DynamoTrace("Sent message from \"", __ident, "\" to \"", _deviceDestination, "\" saying ", _parametersArray);
        }
        
        var _i = 0;
        repeat(array_length(_parametersArray))
        {
            buffer_write(_buffer, buffer_string, string(_parametersArray[_i]));
            ++_i;
        }
        
        if (_suffixBuffer != undefined)
        {
            if (buffer_tell(_buffer) + _suffixSize < buffer_get_size(_buffer))
            {
                buffer_resize(_buffer, buffer_tell(_buffer) + _suffixSize);
                buffer_copy(_suffixBuffer, 0, _suffixSize, _buffer, buffer_tell(_buffer));
                buffer_seek(_buffer, buffer_seek_relative, _suffixSize);
            }
        }
        
        network_send_broadcast(__socket, __serverMode? global.__dynamoCommClientPort : global.__dynamoCommServerPort, _buffer, buffer_tell(_buffer));
        
        buffer_delete(_buffer);
        
        __messageSendTime = current_time;
    }
}
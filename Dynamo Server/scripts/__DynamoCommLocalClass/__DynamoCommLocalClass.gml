function __DynamoCommLocalClass(_serverMode, _ident = undefined) constructor
{
    __serverMode = _serverMode;
    
    __initializeSuccess = false;
    
    __ident = _ident;
    if (__ident == undefined)
    {
        //Generate an ident for this device
        randomize(); //FIXME - Do this without native PRNG
        __ident = string(irandom(999999));
        __DynamoTrace("Chose new device ident \"", __ident, "\"");
    }
    
    __defaultDestination = "all";
    
    __announceLocalTime  = -infinity;
    __messageReceiveTime = -infinity;
    __messageSendTime    = -infinity;
    __warningTime        = -infinity;
    
    
    
    if (__serverMode)
    {
        __DynamoTrace("Running in server mode");
        
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
            return;
        }
        
        __DynamoTrace("Server successfully started");
    }
    else
    {
        __DynamoTrace("Running in client mode");
        
        __port = global.__dynamoCommClientPort;
        __DynamoTrace("Port = ", __port);
        
        __socket = network_create_socket_ext(network_socket_udp, __port);
        __DynamoTrace("Opened a new socket ", __socket, " on port ", __port);
        
        if (__socket < 0)
        {
            __DynamoTrace("Warning! Failed to open client socket");
            return;
        }
        
        __DynamoTrace("Client successfully started");
    }
    
    __initializeSuccess = true;
    
    
    
    
    
    static __EndStep = function()
    {
        if (!__initializeSuccess) return;
        
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
    }
    
    static __Draw = function(_x, _y)
    {
        if (!__initializeSuccess) return;
        
        matrix_stack_push(matrix_build(_x, _y, 0,    0, 0, 0,    1, 1, 1));
        matrix_set(matrix_world, matrix_stack_top());
        
        var _oldFont = draw_get_font();
        draw_set_font(__DynamoDebugFont);
        
        if (current_time - __messageSendTime    <  500) draw_text(   0, 0, "Send"    );
        if (current_time - __messageReceiveTime <  500) draw_text(  50, 0, "Receive" );
        if (current_time - __warningTime    < 1000) draw_text( 100, 0, "Warning!");
        
        var _i = 0;
        repeat(array_length(global.__dynamoCommRemoteArray))
        {
            var _ident = global.__dynamoCommRemoteArray[_i];
            global.__dynamoCommRemoteDictionary[$ _ident].__Draw(0, 15 + 15*_i);
            ++_i;
        }
        
        draw_set_font(_oldFont);
        
        matrix_stack_pop();
        matrix_set(matrix_world, matrix_stack_top());
    }
    
    static __AsyncNetworking = function()
    {
        if (!__initializeSuccess) return;
        
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
                case "ServerDuplicate": _callback = __ReceiveServerDuplicate;                             break;
                case "IAmClient":       _callback = __ReceiveIAmClient;       _verifyDeviceIdent = false; break;
                case "IAmServer":       _callback = __ReceiveIAmServer;       _verifyDeviceIdent = false; break;
                
                default:
                    throw "Command " + string(_parametersArray[0]) + " not supported";
                break;
            }
            
            if (_verifyDeviceIdent)
            {
                if (variable_struct_exists(global.__dynamoCommRemoteDictionary, _deviceIdent))
                {
                    throw "Device ident \"" + string(_deviceIdent) + "\" not recognised (waiting for either \"IAmClient\" or \"IAmServer\" message)";
                }
            }
            
            _callback(_deviceIdent, _deviceDestination, _parametersArray, _buffer);
            
            global.__dynamoCommRemoteDictionary[$ _deviceIdent].__lastReceive = current_time;
        }
        catch(_error)
        {
            __DynamoTrace("Warning! Error encountered whilst decoding buffer");
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
            buffer_write(_buffer, buffer_string, _parametersArray[_i]);
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
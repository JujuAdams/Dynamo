function __DynamoClassFile(_name, _directory, _localPath) constructor
{
    __name = _name;
    __path = _directory + _localPath;
    
    array_push(global.__dynamoFileArray, self);
    global.__dynamoFileStruct[$ __name] = self;
    array_push(global.__dynamoTrackingArray, self);
    
    __contentStub   = true;
    __contentHash   = undefined;
    __contentBuffer = undefined;
    
    __dataFormat = undefined;
    __callback   = undefined;
    
    
    
    static __ContentEnsure = function()
    {
        var _foundHash = __DynamoFileHash(__path);
        if (_foundHash != __contentHash)
        {
            __contentHash = _foundHash;
            
            __contentBuffer = __DynamoLoadBuffer(__path);
            if (__contentBuffer != undefined) __contentStub = false;
        }
        
        return (__contentBuffer != undefined);
    }
    
    static __ContentHasChanged = function()
    {
        return (__DynamoFileHash(__path) != __contentHash);
    }
    
    static __CheckAndLoad = function()
    {
        if (__ContentHasChanged()) __Load();
    }
    
    static __Load = function()
    {
        __ContentEnsure();
        
        var _return = undefined;
        if (__contentBuffer != undefined)
        {
            switch(__dataFormat)
            {
                case "json":
                    var _oldTell = buffer_tell(__contentBuffer);
                    _return = buffer_read(__contentBuffer, buffer_text);
                    buffer_seek(__contentBuffer, buffer_seek_start, _oldTell);
                    
                    try
                    {
                        _return = __DynamoParseJSON(_return);
                    }
                    catch(_error)
                    {
                        __DynamoTrace("Error encountered whilst parsing \"", __path, "\" as JSON");
                        show_debug_message(_error);
                        _return = undefined;
                    }
                break;
                
                case "csv":
                    var _oldTell = buffer_tell(__contentBuffer);
                    _return = buffer_read(__contentBuffer, buffer_text);
                    buffer_seek(__contentBuffer, buffer_seek_start, _oldTell);
                    
                    try
                    {
                        _return = __DynamoParseCSV(_return);
                    }
                    catch(_error)
                    {
                        __DynamoTrace("Error encountered whilst parsing \"", __path, "\" as CSV");
                        show_debug_message(_error);
                        _return = undefined;
                    }
                break;
                
                case "string":
                    if (buffer_get_size(__contentBuffer) == 0)
                    {
                        _return = "";
                    }
                    else
                    {
                        var _oldTell = buffer_tell(__contentBuffer);
                        var _return = buffer_read(__contentBuffer, buffer_text);
                        buffer_seek(__contentBuffer, buffer_seek_start, _oldTell);
                    }
                break;
                
                case "buffer":
                    _return = __contentBuffer;
                break;
                
                default:
                    __DynamoError("Illegal data format (", __dataFormat, ") for file \"", __path, "\"");
                break;
            }
        }
        
        if (is_method(__callback))
        {
            __callback(_return);
        }
        else if (is_numeric(__callback) && script_exists(__callback))
        {
            script_execute(__callback, _return);
        }
        else
        {
            __DynamoError("Illegal callback for file \"", __path, "\"");
        }
    }
}
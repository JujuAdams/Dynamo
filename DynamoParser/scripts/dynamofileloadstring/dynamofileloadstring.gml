/// @param assetName
/// @param [fallback=""]

function DynamoFileLoadString(_assetName, _fallback = "")
{
    __DynamoInit();
    _assetName = string_replace_all(_assetName, "\\", "/");
    
    if (__DYNAMO_DEV_MODE)
    {
        var _assetStruct = global.__dynamoTrackingStruct[$ _assetName];
        if (_assetStruct == undefined) __DynamoError("Asset \"", _assetName, "\" doesn't exist or is not being tracked");
        if (_assetStruct.__type != __DYNAMO_TYPE_FILE) __DynamoError("Asset \"", _assetName, "\" is not an included file");
        
        var _buffer = _assetStruct.__BufferLoad();
        if (_buffer == undefined) return _fallback;
    }
    else
    {
        try
        {
            var _buffer = buffer_load(_assetName);
        }
        catch(_error)
        {
            show_debug_message(_error);
            __DynamoError("Error encountered whilst loading \"", _assetName, "\"");
            
            return _fallback;
        }
    }
    
    if (buffer_get_size(_buffer) == 0)
    {
        var _string = "";
    }
    else
    {
        var _oldTell = buffer_tell(_buffer);
        buffer_seek(_buffer, buffer_seek_start, 0);
        var _string = buffer_read(_buffer, buffer_string);
        buffer_seek(_buffer, buffer_seek_start, _oldTell);
    }
    
    if (!__DYNAMO_DEV_MODE) buffer_delete(_buffer);
    
    return _string;
}
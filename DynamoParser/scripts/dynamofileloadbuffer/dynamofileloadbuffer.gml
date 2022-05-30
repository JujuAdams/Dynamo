/// @param assetName

function DynamoFileLoadBuffer(_assetName)
{
    __DynamoInit();
    _assetName = string_replace_all(_assetName, "\\", "/");
    
    if (__DYNAMO_DEV_MODE)
    {
        var _assetStruct = global.__dynamoTrackingStruct[$ _assetName];
        if (_assetStruct == undefined) __DynamoError("Asset \"", _assetName, "\" doesn't exist or is not being tracked");
        if (_assetStruct.__type != __DYNAMO_TYPE_FILE) __DynamoError("Asset \"", _assetName, "\" is not an included file");
        return _assetStruct.__BufferLoad();
    }
    else
    {
        return buffer_load(_assetName);
    }
}
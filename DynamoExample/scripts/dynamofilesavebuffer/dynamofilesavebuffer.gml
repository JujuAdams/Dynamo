/// @param assetName
/// @param buffer

function DynamoFileSaveBuffer(_assetName, _buffer)
{
    __DynamoInit();
    _assetName = string_replace_all(_assetName, "\\", "/");
    
    if (!__DYNAMO_DEV_MODE)
    {
        if (DYNAMO_VERBOSE) __DynamoTrace("Asset \"", _assetName, "\" cannot be saved as development mode is disabled");
        return;
    }
    
    var _assetStruct = global.__dynamoTrackingStruct[$ _assetName];
    if (_assetStruct == undefined) __DynamoError("Asset \"", _assetName, "\" doesn't exist or is not being tracked");
    if (_assetStruct.__type != __DYNAMO_TYPE_FILE) __DynamoError("Asset \"", _assetName, "\" is not an included file");
    return _assetStruct.__BufferSave(_buffer, true);
}
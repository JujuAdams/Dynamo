/// @param assetName

function DynamoAssetType(_assetName)
{
    __DynamoInit();
    
    if (!__DYNAMO_DEV_MODE)
    {
        if (DYNAMO_VERBOSE) __DynamoTrace("Asset type for \"", _assetName, "\" cannot be resolved as development mode is disabled");
        return "unknown";
    }
    
    _assetName = string_replace_all(_assetName, "\\", "/");
    
    var _assetStruct = global.__dynamoTrackingStruct[$ _assetName];
    if (_assetStruct == undefined) __DynamoError("Asset \"", _assetName, "\" doesn't exist or is not being tracked");
    return _assetStruct.__type;
}
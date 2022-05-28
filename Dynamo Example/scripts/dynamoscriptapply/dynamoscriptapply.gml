/// @param assetName

function DynamoScriptApply(_assetName)
{
    __DynamoInit();
    
    if (!__DYNAMO_DEV_MODE)
    {
        if (DYNAMO_VERBOSE) __DynamoTrace("Asset \"", _assetName, "\" cannot be applied as development mode is disabled");
        return;
    }
    
    var _assetStruct = global.__dynamoTrackingStruct[$ _assetName];
    if (_assetStruct == undefined) __DynamoError("Asset \"", _assetName, "\" doesn't exist or is not being tracked");
    if (_assetStruct.__type != __DYNAMO_TYPE_SCRIPT) __DynamoError("Asset \"", _assetName, "\" is not a script");
    return _assetStruct.__ContentApply();
}
/// @param assetName

function DynamoAssetChanged(_assetName)
{
    __DynamoInit();
    
    if (_assetName == all)
    {
        if (!__DYNAMO_DEV_MODE) return undefined;
        var _result = undefined;
        
        var _i = 0;
        repeat(array_length(global.__dynamoTrackingArray[_i]))
        {
            _assetName = global.__dynamoTrackingArray[_i];
            if (DynamoAssetChanged(_assetName))
            {
                if (!is_array(_result)) _result = [];
                array_push(_result, _assetName);
            }
            
            ++_i;
        }
        
        return _result;
    }
    
    if (!__DYNAMO_DEV_MODE) return false;
    
    _assetName = string_replace_all(_assetName, "\\", "/");
    
    var _assetStruct = global.__dynamoTrackingStruct[$ _assetName];
    if (_assetStruct == undefined) __DynamoError("Asset \"", _assetName, "\" doesn't exist or is not being tracked");
    return _assetStruct.__ContentCheckForChanges();
}
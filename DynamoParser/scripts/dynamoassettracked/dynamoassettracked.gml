/// @param assetName

function DynamoAssetTracked(_assetName)
{
    __DynamoInit();
    if (!__DYNAMO_DEV_MODE) return false;
    
    _assetName = string_replace_all(_assetName, "\\", "/");
    
    return variable_struct_exists(global.__dynamoTrackingStruct, _assetName);
}
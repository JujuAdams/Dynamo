function DynamoScriptAutoGet()
{
    __DynamoInit();
    if (!__DYNAMO_DEV_MODE) return false;
    
    return global.__dynamoScriptAuto;
}
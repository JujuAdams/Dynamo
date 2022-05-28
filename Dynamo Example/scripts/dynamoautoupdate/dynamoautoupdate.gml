function DynamoAutoUpdate()
{
    __DynamoInit();
    if (!__DYNAMO_DEV_MODE) return undefined;
    
    if (global.__dynamoTimeSource == undefined) __DynamoAutoUpdate();
}
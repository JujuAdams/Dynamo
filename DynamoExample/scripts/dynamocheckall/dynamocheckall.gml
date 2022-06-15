function DynamoCheckAll()
{
    if (!__DYNAMO_DEV_MODE) return undefined;
    
    var _i = 0;
    repeat(array_length(global.__dynamoScriptArray))
    {
        global.__dynamoScriptArray[_i].__CheckAndLoad();
        ++_i;
    }
    
    var _i = 0;
    repeat(array_length(global.__dynamoFileArray))
    {
        global.__dynamoFileArray[_i].__CheckAndLoad();
        ++_i;
    }
}
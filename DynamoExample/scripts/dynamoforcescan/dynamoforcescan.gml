function DynamoForceScan()
{
    if (!__DYNAMO_DEV_MODE) return undefined;
    
    var _i = 0;
    repeat(array_length(global.__dynamoScriptArray))
    {
        if (global.__dynamoScriptArray[_i].__HasChanged()) global.__dynamoScriptArray[_i].__Load();
        ++_i;
    }
    
    var _i = 0;
    repeat(array_length(global.__dynamoFileArray))
    {
        if (global.__dynamoFileArray[_i].__HasChanged()) global.__dynamoFileArray[_i].__Load();
        ++_i;
    }
}
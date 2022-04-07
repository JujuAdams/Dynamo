function __DynamoEnsureNoteDictionary()
{
    if (!global.__dynamoNoteDictionaryBuilt)
    {
        global.__dynamoNoteDictionary = __DynamoNoteDictionary();
        global.__dynamoNoteDictionaryBuilt = true;
    }
}
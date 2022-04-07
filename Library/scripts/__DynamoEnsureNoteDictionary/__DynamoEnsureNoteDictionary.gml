function __DynamoEnsureNoteDictionary()
{
    if (!global.__dynamoNoteDictionaryBuilt)
    {
        global.__dynamoNoteDictionaryBuilt = true;
        global.__dynamoNoteDictionary = __DynamoNoteDictionary();
    }
}
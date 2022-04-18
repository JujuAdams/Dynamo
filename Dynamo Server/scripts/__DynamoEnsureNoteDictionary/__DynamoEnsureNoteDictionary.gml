function __DynamoEnsureNoteDictionary()
{
    if (__DYNAMO_DEV_MODE && !global.__dynamoNoteDictionaryBuilt)
    {
        global.__dynamoNoteDictionaryBuilt = true;
        global.__dynamoNoteDictionary = __DynamoNotesDictionary(DynamoDevProjectDirectory());
    }
}
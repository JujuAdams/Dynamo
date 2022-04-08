function __DynamoEnsureNoteDictionary()
{
    if (__DYNAMO_DEV_MODE && !global.__dynamoNoteDictionaryBuilt)
    {
        global.__dynamoNoteDictionaryBuilt = true;
        
        __DynamoEnsureProjectDirectory();
        global.__dynamoNoteDictionary = __DynamoNotesDictionary(global.__dynamoProjectDirectory);
    }
}
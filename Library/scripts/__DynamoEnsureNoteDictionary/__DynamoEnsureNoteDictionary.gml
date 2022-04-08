function __DynamoEnsureNoteDictionary()
{
    if (__DYNAMO_DEV_MODE && !global.__dynamoNoteDictionaryBuilt)
    {
        global.__dynamoNoteDictionaryBuilt = true;
        
        __DynamoEnsureProjectDirectory();
        
        var _projectJSON = __DynamoParseMainProjectJSON(global.__dynamoProjectDirectory);
        if (_projectJSON == undefined)
        {
            __DynamoTrace("Failed to verify main project file");
            return;
        }
        
        global.__dynamoNoteDictionary = __DynamoMainProjectNotesDictionary(_projectJSON, global.__dynamoProjectDirectory);
    }
}
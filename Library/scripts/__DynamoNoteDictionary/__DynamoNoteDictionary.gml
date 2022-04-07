function __DynamoNoteDictionary()
{
    if (__DYNAMO_DEV_MODE)
    {
        __DynamoEnsureProjectDirectory();
        
        var _json = __DynamoParseMainProjectJSON(global.__dynamoProjectDirectory);
        return __DynamoMainProjectNotesDictionary(_json, global.__dynamoProjectDirectory);
    }
    else
    {
        return __DynamoManifestNotesDictionary("manifest.dynamo");
    }
}
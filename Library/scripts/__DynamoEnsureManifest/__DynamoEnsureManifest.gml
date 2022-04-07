function __DynamoEnsureManifest()
{
    if (global.__dynamoNoteDictionaryBuilt) return;
    global.__dynamoNoteDictionaryBuilt = true;
    
    if (__DYNAMO_DEV_MODE)
    {
        __DynamoEnsureProjectDirectory();
        
        var _json = __DynamoParseMainProjectJSON(global.__dynamoProjectDirectory);
        var _noteArray = __DynamoMainProjectNotesArray(_json, global.__dynamoProjectDirectory);
    }
    else
    {
        var _noteArray = __DynamoManifestNotesArray("manifest.dynamo");
    }
    
    //And initialize hashes for each asset
    var _i = 0;
    repeat(array_length(_noteArray))
    {
        _noteArray[_i].__HashInitialize();
        ++_i;
    }
}
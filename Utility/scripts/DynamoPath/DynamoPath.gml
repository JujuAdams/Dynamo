function DynamoPath(_name)
{
    if (global.__dynamoRunningFromIDE && !DYNAMO_FORCE_LOAD_FROM_BINARY)
    {
        return _name + ".txt";
    }
    else
    {
        var _nameHash = __DynamoNameHash(_name);
        __DynamoEnsureManifestLoaded();
        
        if (!variable_struct_exists(global.__dynamoManifestDictionary, _nameHash))
        {
            __DynamoError("Could not find \"", _name, "\" in manifest (via hash as \"", _nameHash, "\")");
            return undefined;
        }
        
        return "dynamo_" + _nameHash;
    }
}
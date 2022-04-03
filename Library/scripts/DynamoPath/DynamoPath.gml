function DynamoPath(_name)
{
    __DynamoEnsureManifest();
    
    var _nameHash = __DynamoNameHash(_name);
    
    if (!variable_struct_exists(global.__dynamoNoteDictionary, _nameHash))
    {
        __DynamoError("Could not find \"", _name, "\" in manifest (via hash as \"", _nameHash, "\")");
        return undefined;
    }
    
    return global.__dynamoNoteDictionary[$ _nameHash].__sourcePath;
}
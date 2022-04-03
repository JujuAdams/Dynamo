function DynamoDevCheckForChanges()
{
    if (!__DYNAMO_DEV_MODE) return undefined;
    
    __DynamoEnsureManifest();
    
    var _output = undefined;
    
    var _nameHashArray = variable_struct_get_names(global.__dynamoNoteDictionary);
    var _i = 0;
    repeat(array_length(_nameHashArray))
    {
        var _note = global.__dynamoNoteDictionary[$ _nameHashArray[_i]];
        if (_note.__CheckForChange())
        {
            if (!is_array(_output)) _output = [];
            array_push(_output, _note.__name);
        }
        
        ++_i;
    }
    
    return _output;
}
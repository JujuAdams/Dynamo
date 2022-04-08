/// @param outputArray
/// @param projectDirectory
/// @param targetDirectory

function __DynamoCheckForNoteChanges(_output, _projectDirectory, _targetDirectory)
{
    var _oldDictionary = global.__dynamoNoteDictionary;
    var _oldNameHashes = variable_struct_get_names(_oldDictionary);
    
    var _projectJSON = __DynamoParseMainProjectJSON(_projectDirectory);
    if (_projectJSON == undefined)
    {
        __DynamoTrace("Failed to verify main project file");
        return _output;
    }
    
    var _newDictionary = __DynamoMainProjectNotesDictionary(_projectJSON, _projectDirectory);
    var _newNameHashes = variable_struct_get_names(_newDictionary);
    
    global.__dynamoNoteDictionaryBuilt = true;
    global.__dynamoNoteDictionary = _newDictionary;
    
    var _i = 0;
    repeat(array_length(_oldNameHashes))
    {
        var _nameHash = _oldNameHashes[_i];
        
        if (!variable_struct_exists(_newDictionary, _nameHash))
        {
            var _oldNote = _oldDictionary[$ _nameHash];
            __DynamoTrace("\"", _oldNote.__name, "\" has been deleted (name hash = ", _nameHash, ")");
            
            if (!is_array(_output)) _output = [];
            array_push(_output, _oldNote.__name);
            
            file_delete(_targetDirectory + _nameHash + ".dynamo");
            __DynamoTrace("Deleted \"", _targetDirectory + _nameHash + ".dynamo", "\"");
        }
        
        ++_i;
    }
    
    var _i = 0;
    repeat(array_length(_newNameHashes))
    {
        var _nameHash = _newNameHashes[_i];
        var _newNote = _newDictionary[$ _nameHash];
        
        if (!variable_struct_exists(_oldDictionary, _nameHash))
        {
            __DynamoTrace("\"", _newNote.__name, "\" has been created (name hash = ", _nameHash, ")");
            
            if (!is_array(_output)) _output = [];
            array_push(_output, _newNote.__name);
            
            file_copy(_newNote.__sourcePath, _targetDirectory + _nameHash + ".dynamo");
            __DynamoTrace("Copied \"", _newNote.__sourcePath, "\" to \"", _targetDirectory + _nameHash + ".dynamo", "\"");
        }
        else
        {
            var _oldNote = _oldDictionary[$ _nameHash];
            
            var _oldNameHash = _oldNote.__dataHash;
            var _newNameHash = _newNote.__dataHash;
            
            if (_oldNameHash != _newNameHash)
            {
                __DynamoTrace("Hash for \"", _oldNote.__name, "\" (name hash = ", _nameHash, ") has changed (old = \"", _oldNameHash, "\" vs. new = \"", _newNameHash, "\"");
                
                if (!is_array(_output)) _output = [];
                array_push(_output, _oldNote.__name);
                
                file_copy(_newNote.__sourcePath, _targetDirectory + _nameHash + ".dynamo");
                __DynamoTrace("Copied \"", _newNote.__sourcePath, "\" to \"", _targetDirectory + _nameHash + ".dynamo", "\" (overwrite)");
            }
        }
        
        ++_i;
    }
    
    return _output;
}
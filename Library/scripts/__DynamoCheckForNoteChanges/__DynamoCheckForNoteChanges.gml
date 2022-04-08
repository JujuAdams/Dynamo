/// @param outputArray
/// @param projectDirectory
/// @param targetDirectory

function __DynamoCheckForNoteChanges(_output, _projectDirectory, _targetDirectory)
{
    var _oldDictionary = global.__dynamoNoteDictionary;
    var _oldNameHashes = variable_struct_get_names(_oldDictionary);
    
    var _newDictionary = __DynamoNotesDictionary(_projectDirectory);
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
        
        var _copy = false;
        
        if (!variable_struct_exists(_oldDictionary, _nameHash))
        {
            __DynamoTrace("\"", _newNote.__name, "\" has been created (name hash = ", _nameHash, ")");
            
            if (!is_array(_output)) _output = [];
            array_push(_output, _newNote.__name);
            
            _copy = true;
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
                
                _copy = true;
            }
        }
        
        if (_copy)
        {
            if (_newNote.__dataHash == "")
            {
                var _buffer = buffer_create(1, buffer_fixed, 1);
                buffer_save(_buffer, _targetDirectory + _nameHash + ".dynamo");
                buffer_delete(_buffer);
                
                __DynamoTrace("\"", _newNote.__sourcePath, "\" is empty, saving an empty buffer to \"", _targetDirectory + _nameHash + ".dynamo", "\"");
            }
            else
            {
                file_copy(_newNote.__sourcePath, _targetDirectory + _nameHash + ".dynamo");
                __DynamoTrace("Copied \"", _newNote.__sourcePath, "\" to \"", _targetDirectory + _nameHash + ".dynamo", "\"");
            }
        }
        
        ++_i;
    }
    
    return _output;
}
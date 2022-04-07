/// Checks for changes to Note assets in your project directory
/// 
///   N.B. You should *NOT* call this function every frame as it is slow and will cause significant
///        performance issues. Instead, consider using DynamoDevCheckForChangesOnRefocus() or call
///        this function on a keypress (such as F5)
/// 
/// Returns an array containing the names of Notes that have changed. If no Notes have changed then
/// this function returns <undefined>
/// 
/// This function is only avaiable when running from the IDE and if DYNAMO_DEV_MODE is set to <true>

function DynamoDevCheckForChanges()
{
    //Guarantee we're initialized
    __DynamoInit();
    
    //Though if we're not in dev mode then ignore this function
    //(This macro is set to <false> if we're not running from the IDE as well)
    if (!__DYNAMO_DEV_MODE) return undefined;
    
    var _output = undefined;
    
    
    
    #region Check note assets
    
    __DynamoEnsureNoteDictionary();
    
    var _oldDictionary = global.__dynamoNoteDictionary;
    var _oldNameHashes = variable_struct_get_names(_oldDictionary);
    
    var _newDictionary = __DynamoNoteDictionary();
    var _newNameHashes = variable_struct_get_names(_newDictionary);
    
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
        }
        
        ++_i;
    }
    
    var _i = 0;
    repeat(array_length(_newNameHashes))
    {
        var _nameHash = _newNameHashes[_i];
        var _newNote = _oldDictionary[$ _nameHash];
        
        if (!variable_struct_exists(_oldDictionary, _nameHash))
        {
            __DynamoTrace("\"", _newNote.__name, "\" has been created (name hash = ", _nameHash, ")");
            
            if (!is_array(_output)) _output = [];
            array_push(_output, _newNote.__name);
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
            }
        }
        
        ++_i;
    }
    
    #endregion
    
    
    
    #region Check datafiles
    
    var _datafilesDynamoPath       = global.__dynamoProjectDirectory + "datafilesDynamo\\";
    var _datafilesDynamoPathLength = string_length(_datafilesDynamoPath);
    
    var _oldDictionary = global.__dynamoFileDictionary;
    var _oldPaths = variable_struct_get_names(_oldDictionary);
    
    var _newDictionary = __DynamoDatafilesDictionary(_datafilesDynamoPath, {});
    var _newPaths = variable_struct_get_names(_newDictionary);
    
    global.__dynamoFileDictionary = _newDictionary;
    
    
    
    var _deleteArray          = [];
    var _createDirectoryArray = [];
    var _copyArray            = [];
    
    var _i = 0;
    repeat(array_length(_oldPaths))
    {
        var _path = _oldPaths[_i];
        if (!variable_struct_exists(_newDictionary, _path))
        {
            __DynamoTrace("\"", _path, "\" has been deleted");
            array_push(_deleteArray, _path);
        }
        
        ++_i;
    }
    
    var _i = 0;
    repeat(array_length(_newPaths))
    {
        var _path = _newPaths[_i];
        if (!variable_struct_exists(_oldDictionary, _path))
        {
            __DynamoTrace("\"", _path, "\" has been created");
            
            if (_newDictionary[$ _path].__isDirectory)
            {
                array_push(_createDirectoryArray, _path);
            }
            else
            {
                array_push(_copyArray, _path);
            }
        }
        else
        {
            var _oldHash = _oldDictionary[$ _path].__dataHash;
            var _newHash = _newDictionary[$ _path].__dataHash;
            
            if (_oldHash != _newHash)
            {
                __DynamoTrace("Hash for \"", _path, "\" has changed (old = \"", _oldHash, "\" vs. new = \"", _newHash, "\"");
                array_push(_copyArray, _path);
            }
        }
        
        ++_i;
    }
    
    var _i = 0;
    repeat(array_length(_deleteArray))
    {
        var _sourcePath = _deleteArray[_i];
        var _localPath = string_delete(_sourcePath, 1, _datafilesDynamoPathLength);
        
        if (!is_array(_output)) _output = [];
        array_push(_output, _localPath);
        
        var _destinationPath = global.__dynamoWorkingDirectory + _localPath;
        __DynamoTrace("Deleting \"", _destinationPath, "\"");
        
        if (_oldDictionary[$ _sourcePath].__isDirectory)
        {
            directory_destroy(_destinationPath);
        }
        else
        {
            file_delete(_destinationPath);
        }
        
        ++_i;
    }
    
    array_sort(_createDirectoryArray, true);
    
    var _i = 0;
    repeat(array_length(_createDirectoryArray))
    {
        var _sourcePath = _createDirectoryArray[_i];
        var _localPath = string_delete(_sourcePath, 1, _datafilesDynamoPathLength);
        
        if (!is_array(_output)) _output = [];
        array_push(_output, _localPath);
        
        var _destinationPath = global.__dynamoWorkingDirectory + _localPath;
        __DynamoTrace("Creating \"", _destinationPath, "\"");
        
        directory_create(_destinationPath);
        
        ++_i;
    }
    
    var _i = 0;
    repeat(array_length(_copyArray))
    {
        var _sourcePath = _copyArray[_i];
        var _localPath = string_delete(_sourcePath, 1, _datafilesDynamoPathLength);
        
        if (!is_array(_output)) _output = [];
        array_push(_output, _localPath);
        
        var _destinationPath = global.__dynamoWorkingDirectory + _localPath;
        __DynamoTrace("Copying \"", _sourcePath, "\" to \"", _destinationPath, "\"");
        
        file_copy(_sourcePath, _destinationPath);
        
        ++_i;
    }
    
    #endregion
    
    
    
    return _output;
}
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
    
    
    
    var _datafilesDynamoPath       = global.__dynamoProjectDirectory + "datafilesDynamo\\";
    var _datafilesDynamoPathLength = string_length(_datafilesDynamoPath);
    
    var _oldDictionary = global.__dynamoFileDictionary;
    var _oldPaths = variable_struct_get_names(_oldDictionary);
    
    var _newDictionary = __DynamoRecursiveFileSearch(_datafilesDynamoPath, {});
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
    
    
    
    return _output;
}
/// @param name
/// @param originalPath
/// @param backupPath

function __DynamoAddRestorableFile(_name, _originalPath, _backupPath)
{
    var _i = 0;
    repeat(array_length(global.__dynamoRestoreArray))
    {
        if (global.__dynamoRestoreArray[_i].__originalPath == _originalPath)
        {
            __DynamoError("Old path \"", _originalPath , "\" already has an entry");
            return;
        }
        
        ++_i;
    }
    
    array_push(global.__dynamoRestoreArray, {
        __name: _name,
        __originalPath: _originalPath,
        __backupPath: _backupPath,
    });
    
    file_copy(_originalPath, _backupPath);
}
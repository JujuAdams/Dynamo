/// @param name
/// @param originalPath

function __DynamoRegisterBackup(_name, _originalPath)
{
    var _backupPath = filename_change_ext(_originalPath, ".backup");
    
    var _i = 0;
    repeat(array_length(global.__dynamoBackupArray))
    {
        if (global.__dynamoBackupArray[_i].__originalPath == _originalPath)
        {
            __DynamoError("Old path \"", _originalPath , "\" already has an entry");
            return;
        }
        
        ++_i;
    }
    
    array_push(global.__dynamoBackupArray, {
        __name: _name,
        __originalPath: _originalPath,
        __backupPath: _backupPath,
    });
    
    file_copy(_originalPath, _backupPath);
}
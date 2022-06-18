function __DynamoPrepareGMLFile(_name, _path)
{
    if (!file_exists(_path)) __DynamoError("Could not find \"", _path, "\"");
    
    __DynamoRegisterBackup(_name, _path);
}
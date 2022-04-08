function __DynamoClassFile(_sourcePath, _isDirectory) constructor
{
    __isDirectory = _isDirectory;
    __sourcePath  = _sourcePath;
    __dataHash    = __isDirectory? "<directory>" : md5_file(__sourcePath);
    
    __DynamoTrace("File instance for \"", __sourcePath, "\" created, hash = \"", __dataHash, "\"");
}
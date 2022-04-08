function __DynamoClassNote(_name, _sourcePath) constructor
{
    __name       = _name;
    __nameHash   = __DynamoNameHash(__name);
    __sourcePath = _sourcePath;
    __dataHash   = md5_file(__sourcePath);
    
    __DynamoTrace("Note instance for \"", __name, "\" found, hash = \"", __dataHash, "\" (", __sourcePath, ")");
}
function __DynamoClassNote(_name, _sourcePath, _nameHash) constructor
{
    __name       = _name;
    __nameHash   = (_nameHash == undefined)? __DynamoNameHash(__name) : _nameHash;
    __sourcePath = _sourcePath;
    __dataHash   = md5_file(__sourcePath);
    
    __DynamoTrace("Note instance for \"", __name, "\" created, hash = \"", __dataHash, "\" (", __sourcePath, ")");
}
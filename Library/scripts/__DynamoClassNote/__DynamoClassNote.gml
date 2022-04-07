function __DynamoClassNote(_name, _sourcePath, _nameHash) constructor
{
    __name       = _name;
    __nameHash   = (_nameHash == undefined)? __DynamoNameHash(__name) : _nameHash;
    __sourcePath = _sourcePath;
    __dataHash   = md5_file(__sourcePath);
    
    __DynamoTrace("Note instance for \"", __name, "\" created, hash = \"", __dataHash, "\" (", __sourcePath, ")");
    
    
    
    static __Export = function(_outputDirectory)
    {
        //Save out this asset to the target datafiles folder
        if (file_exists(__sourcePath))
        {
            var _txtBuffer = buffer_load(__sourcePath);
        }
        else
        {
            var _txtBuffer = buffer_create(1, buffer_fixed, 1);
        }
        
        var _outputPath = _outputDirectory + __nameHash + ".dynamo";
        buffer_save(_txtBuffer, _outputPath);
        __DynamoTrace("Saved \"", __name, "\" to \"", _outputPath + "\"");
    }
}
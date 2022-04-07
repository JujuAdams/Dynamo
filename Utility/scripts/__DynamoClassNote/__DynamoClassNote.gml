function __DynamoClassNote(_name, _sourcePath, _nameHash) constructor
{
    __name       = _name;
    __nameHash   = (_nameHash == undefined)? __DynamoNameHash(__name) : _nameHash;
    __sourcePath = _sourcePath;
    __dataHash   = undefined;
    
    global.__dynamoNoteDictionary[$ __nameHash] = self;
    
    static __HashInitialize = function()
    {
        if (__dataHash == undefined)
        {
            __dataHash = md5_file(__sourcePath);
            __DynamoTrace("\"", __name, "\" hash = \"", __dataHash, "\" (", __sourcePath, ")");
        }
    }
    
    static __CheckForChange = function()
    {
        if (!file_exists(__sourcePath))
        {
            var _newHash = "";
            __DynamoTrace("\"", __name, "\" doesn't exist, new hash = \"", _newHash, "\" vs. old hash = \"", __dataHash, "\" (", __sourcePath, ")");
        }
        else
        {
            var _newHash = md5_file(__sourcePath);
            
            if (__dataHash == undefined)
            {
                __DynamoTrace("\"", __name, "\" newly found, hash = \"", _newHash, "\" (", __sourcePath, ")");
            }
            else
            {
                __DynamoTrace("\"", __name, "\" new hash = \"", _newHash, "\" vs. old hash = \"", __dataHash, "\" (", __sourcePath, ")");
            }
        }
        
        if (_newHash != __dataHash)
        {
            __DynamoTrace("\"", __name, "\" changed");
            __dataHash = _newHash;
            
            return true;
        }
        else
        {
            __DynamoTrace("\"", __name, "\" did not change");
        }
        
        return false;
    }
    
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
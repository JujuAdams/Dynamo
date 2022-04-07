function __DynamoClassFile(_sourcePath, _isDirectory) constructor
{
    __isDirectory = _isDirectory;
    __sourcePath  = _sourcePath;
    __dataHash    = undefined;
    
    __HashInitialize();
    
    static __HashInitialize = function()
    {
        if (__dataHash == undefined)
        {
            if (__isDirectory)
            {
                __dataHash = "<directory>";
            }
            else
            {
                __dataHash = md5_file(__sourcePath);
            }
            
            __DynamoTrace("\"", __sourcePath, "\" hash = \"", __dataHash, "\"");
        }
    }
    
    static __CheckForChange = function()
    {
        if (__isDirectory)
        {
            if (directory_exists(__sourcePath))
            {
                var _newHash = "<directory>";
            }
            else
            {
                var _newHash = "";
                __DynamoTrace("\"", __sourcePath, "\" doesn't exist");
            }
        }
        else
        {
            if (!file_exists(__sourcePath))
            {
                var _newHash = "";
                __DynamoTrace("\"", __sourcePath, "\" doesn't exist, new hash = \"", _newHash, "\" vs. old hash = \"", __dataHash, "\"");
            }
            else
            {
                var _newHash = md5_file(__sourcePath);
                
                if (__dataHash == undefined)
                {
                    __DynamoTrace("\"", __sourcePath, "\" newly found, hash = \"", _newHash, "\"");
                }
                else
                {
                    __DynamoTrace("\"", __sourcePath, "\" new hash = \"", _newHash, "\" vs. old hash = \"", __dataHash, "\"");
                }
            }
        }
        
        if (_newHash != __dataHash)
        {
            __DynamoTrace("\"", __sourcePath, "\" changed");
            __dataHash = _newHash;
            
            return true;
        }
        else
        {
            __DynamoTrace("\"", __sourcePath, "\" did not change");
        }
        
        return false;
    }
}
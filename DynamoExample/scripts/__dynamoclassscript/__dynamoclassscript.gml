function __DynamoClassScript(_path) constructor
{
    static __type = __DYNAMO_TYPE_SCRIPT;
    
    __path = _path;
    
    __metadataStub = true;
    __metadataHash = undefined;
    
    __contentStub   = true;
    __contentHash   = undefined;
    __contentPath   = undefined;
    __contentString = "";
    
    __json = {};
    
    static __Track = function()
    {
        if (!__MetadataEnsure()) return;
        
        var _name = __GetName();
        array_push(global.__dynamoTrackingArray, _name);
        global.__dynamoTrackingStruct[$ _name] = self;
    }
    
    static __MetadataEnsure = function(_dontCheckHash = true)
    {
        var _foundHash = (_dontCheckHash && (__metadataHash != undefined) && !__metadataStub)? __metadataHash : __DynamoFileHash(__path);
        if (_foundHash != __metadataHash)
        {
            __metadataHash = _foundHash;
            
            __json = __DynamoLoadJSON(__path, undefined);
            if (is_struct(__json))
            {
                __metadataStub = false;
                __contentPath = filename_dir(__path) + "/" + __json.name + ".gml";
            }
        }
        
        return is_struct(__json);
    }
    
    static __ContentEnsure = function(_dontCheckHash = true)
    {
        if (__contentPath == undefined) __MetadataEnsure(false);
        if (__contentPath == undefined) return false;
        
        var _foundHash = (_dontCheckHash && (__contentHash != undefined) && !__contentStub)? __contentHash : __DynamoFileHash(__contentPath);
        if (_foundHash != __contentHash)
        {
            __contentHash = _foundHash;
            
            __contentString = __DynamoLoadString(__contentPath, "");
            if (__contentString != "") __contentStub = false;
        }
        
        return (__contentString != "");
    }
    
    static __TagAnyMatches = function(_tag)
    {
        if (!__MetadataEnsure()) return false;
        
        var _tagArray = __json.tags;
        var _i = 0;
        repeat(array_length(_tagArray))
        {
            if (_tagArray[_i] == _tag) return true;
            ++_i;
        }
        
        return false;
    }
    
    static __Check = function()
    {
        return __ContentApply();
    }
    
    static __ContentApply = function()
    {
        if (!__MetadataEnsure(false)) return false;
        if (!__ContentCheckForChanges()) return false;
        if (!__ContentEnsure(false)) return false;
        
        if (DYNAMO_VERBOSE) __DynamoTrace("Changes found in \"", __contentPath, "\"");
        
        try
        {
            var _data = __DynamoGMLToJSON(__contentString);
        }
        catch(_error)
        {
            __DynamoTrace("Warning! Error encountered whilst parsing \"", __contentPath, "\"\n", _error);
            return false;
        }
        
        if (!is_struct(_data))
        {
            __DynamoTrace("Warning! Could not apply content for \"", __contentPath, "\"");
            return false;
        }
        
        var _topLevelNamesArray = variable_struct_get_names(_data);
        var _i = 0;
        repeat(array_length(_topLevelNamesArray))
        {
            var _topLevelName = _topLevelNamesArray[_i];
            
            if (string_copy(_topLevelName, 1, 7) != "global.")
            {
                __DynamoTrace("Warning! Top level name \"", _topLevelName, "\" is invalid");
                ++_i;
                continue;
            }
            
            var _variableName = string_delete(_topLevelName, 1, 7);
            var _value = _data[$ _topLevelName];
            
            if (DYNAMO_VERBOSE) __DynamoTrace("Setting \"", _topLevelName, "\" to ", typeof(_value));
            variable_global_set(_variableName, _value);
            
            ++_i;
        }
        
        return true;
    }
    
    static __ContentCheckForChanges = function()
    {
        if (!__MetadataEnsure()) return false;
        return (__DynamoFileHash(__contentPath) != __contentHash);
    }
    
    static __GetName = function()
    {
        if (!__MetadataEnsure()) return "<unknown script>";
        return __json.name;
    }
    
    static toString = function()
    {
        return __GetName();
    }
}
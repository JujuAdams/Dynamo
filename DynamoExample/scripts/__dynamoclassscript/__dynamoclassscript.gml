function __DynamoClassScript(_name, _path) constructor
{
    __name = _name;
    __path = _path;
    
    array_push(global.__dynamoScriptArray, self);
    global.__dynamoScriptStruct[$ __name] = self;
    array_push(global.__dynamoTrackingArray, self);
    
    __metadataStub = true;
    __metadataHash = undefined;
    
    __contentStub   = true;
    __contentHash   = undefined;
    __contentPath   = undefined;
    __contentString = "";
    
    __callback = undefined;
    
    __json = {};
    
    
    
    static __MetadataEnsure = function()
    {
        var _foundHash = __DynamoFileHash(__path);
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
    
    static __ContentEnsure = function()
    {
        if (__contentPath == undefined) __MetadataEnsure();
        if (__contentPath == undefined) return false;
        
        var _foundHash = __DynamoFileHash(__contentPath);
        if (_foundHash != __contentHash)
        {
            __contentHash = _foundHash;
            
            __contentString = __DynamoLoadString(__contentPath, "");
            if (__contentString != "") __contentStub = false;
        }
        
        return (__contentString != "");
    }
    
    static __ContentHasChanged = function()
    {
        if (!__MetadataEnsure()) return false;
        return (__DynamoFileHash(__contentPath) != __contentHash);
    }
    
    static __CheckAndLoad = function()
    {
        if (__ContentHasChanged()) __Load();
    }
    
    static __Load = function()
    {
        __MetadataEnsure();
        __ContentEnsure();
        
        try
        {
            var _data = __DynamoGMLToJSON(__contentString);
        }
        catch(_error)
        {
            __DynamoTrace("Warning! Error encountered whilst parsing \"", __contentPath, "\" as a script");
            show_debug_message(_error);
            return;
        }
        
        if (!is_struct(_data))
        {
            __DynamoTrace("Warning! Could not apply content for \"", __contentPath, "\"");
            return;
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
        
        if (is_method(__callback))
        {
            __callback();
        }
        else if (is_numeric(__callback) && script_exists(__callback))
        {
            script_execute(__callback);
        }
        else if (!is_undefined(__callback))
        {
            __DynamoError("Illegal callback for script \"", __name, "\"");
        }
    }
}
function __DynamoClassScript(_name, _path) constructor
{
    __name = _name;
    __path = _path;
    
    array_push(global.__dynamoScriptArray, self);
    global.__dynamoScriptStruct[$ __name] = self;
    array_push(global.__dynamoTrackingArray, self);
    
    __hash = undefined;
    
    __callback = undefined;
    
    
    
    static __HasChanged = function()
    {
        return (__DynamoFileHash(__path) != __hash);
    }
    
    static __Load = function()
    {
        __hash = __DynamoFileHash(__path);
        
        try
        {
            var _string = __DynamoLoadString(__path, "");
            var _data = __DynamoParseGML(_string);
        }
        catch(_error)
        {
            __DynamoTrace("Warning! Error encountered whilst parsing \"", __path, "\" as a script");
            show_debug_message(_error);
            return;
        }
        
        if (!is_struct(_data))
        {
            __DynamoTrace("Warning! Could not apply content for \"", __path, "\"");
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
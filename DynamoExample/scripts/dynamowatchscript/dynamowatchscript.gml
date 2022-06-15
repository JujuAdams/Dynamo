/// Script contents are always returned as JSON
/// 
/// @param script
/// @param [callback]

function DynamoWatchScript(_script, _callback = undefined)
{
    __DynamoInitialize();
    
    if (__DYNAMO_DEV_MODE)
    {
        if (!is_numeric(_script)) __DynamoError("Illegal datatype passed for the script index (was ", typeof(_script), ")");
        if (!script_exists(_script)) __DynamoError("Script with index ", _script, " doesn't exist");
        
        if (is_numeric(_callback))
        {
            if (!script_exists(_callback)) __DynamoError("Callback script with index ", _callback, " doesn't exist");
        }
        else if (!is_method(_callback) && (_callback != undefined))
        {
            __DynamoError("Illegal datatype passed for the callback (was ", typeof(_callback), ")");
        }
        
        var _scriptName = script_get_name(_script);
        if (variable_struct_exists(global.__dynamoScriptStruct, _scriptName)) __DynamoError("Script \"", _scriptName, "\" is already being watched");
        
        var _watcher = new __DynamoClassScript(_scriptName, global.__dynamoProjectDirectory + "scripts/" + string_lower(_scriptName) + "/" + string_lower(_scriptName) + ".yy");
        _watcher.__callback = _callback;
    }
}
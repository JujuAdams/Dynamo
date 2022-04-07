function __DynamoInit()
{
    if (variable_global_exists("__dynamoInFocus")) return;
    
    global.__dynamoInFocus = true;
    
    global.__dynamoNoteDictionaryBuilt = false;
    global.__dynamoNoteDictionary = {};
    
    global.__dynamoFileDictionary = {};
    
    global.__dynamoProjectDirectory = undefined;
    global.__dynamoWorkingDirectory = undefined;
    
    
    
    global.__dynamoRunningFromIDE = false;
    
    if (code_is_compiled() && (parameter_count() == 1))
    {
        var _path = filename_dir(parameter_string(0));
        
        var _last_folder = _path;
        do
        {
            var _pos = string_pos("\\", _last_folder);
            if (_pos > 0) _last_folder = string_delete(_last_folder, 1, _pos);
        }
        until (_pos <= 0);
        
        var _last_four = string_copy(_last_folder, string_length(_last_folder) - 3, 4);
        var _filename = filename_change_ext(filename_name(parameter_string(0)), "");
        
        if ((_last_four == "_YYC")
        &&  (string_length(_last_folder) - string_length(_filename) == 13))
        {
            global.__dynamoRunningFromIDE = true;
        }
    }
    else
    {
        if ((parameter_count() == 3)
        &&  (filename_name(parameter_string(0)) == "Runner.exe")
        &&  (parameter_string(1) == "-game")
        &&  (filename_ext(parameter_string(2)) == ".win"))
        {
            global.__dynamoRunningFromIDE = true;
        }
    }
    
    
    
    if (__DYNAMO_DEV_MODE)
    {
        __DynamoEnsureProjectDirectory();
        
        global.__dynamoWorkingDirectory = global.__dynamoProjectDirectory + "datafilesDynamo\\linkToWorkingDirectory.dynamo\\";
        __DynamoTrace("Working directory = \"", global.__dynamoWorkingDirectory, "\"");
        
        global.__dynamoFileDictionary = __DynamoRecursiveFileSearch(global.__dynamoProjectDirectory + "datafilesDynamo\\", {});
    }
}

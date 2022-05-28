function __DynamoRunningFromIDE()
{
    if (((os_type != os_windows) && (os_type != os_macosx)) || (os_browser != browser_not_a_browser))
    {
        if (DYNAMO_ENABLED) __DynamoTrace("Warning! Dynamo can only run in dev mode on Windows and MacOS. Development mode is disabled on this platform");
        return false;
    }
    else
    {
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
                return true;
            }
        }
        else
        {
            if ((parameter_count() == 3)
            &&  (filename_name(parameter_string(0)) == "Runner.exe")
            &&  (parameter_string(1) == "-game")
            &&  (filename_ext(parameter_string(2)) == ".win"))
            {
                return true;
            }
        }
    }
    
    __DynamoTrace("Running from executable. Development mode is disabled");
    
    return false;
}
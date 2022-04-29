#macro __DYNAMO_VERSION       "2.0.0 alpha 2"
#macro __DYNAMO_DATE          "2022-04-18"
#macro __DYNAMO_DEV_MODE      (DYNAMO_DEV_MODE && global.__dynamoRunningFromIDE)

#macro __DYNAMO_COMM_VERBOSE_SEND         true
#macro __DYNAMO_COMM_VERBOSE_RECEIVE      true
#macro __DYNAMO_DEBUG_CLIENT              (false && global.__dynamoRunningFromIDE)
#macro __DYNAMO_ALLOW_NONMATCHING_SERVER  true

#macro __DYNAMO_PROJECT_DIRECTORY_PATH_NAME        "projectDirectoryPath"
#macro __DYNAMO_SYMLINK_TO_WORKING_DIRECTORY_NAME  "symlinkToWorkingDirectory"

__DynamoTrace("Welcome to Dynamo by @jujuadams! This is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE);

global.__dynamoCommExpectedServerIdent = undefined;
global.__dynamoCommServerPort          = 102110;
global.__dynamoCommClientPort          = 102111;
global.__dynamoCommServerTempDirectory = temp_directory + "dynamo_coordination\\";
global.__dynamoCommLocal               = undefined;
global.__dynamoCommRemoteArray         = [];
global.__dynamoCommRemoteDictionary    = {};
global.__dynamoCommTimeout             = 10000;
global.__dynamoCommServerAliases       = {};



__DynamoInit();

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
    
    if (os_type != os_windows)
    {
        if (DYNAMO_DEV_MODE) __DynamoTrace("Warning! Dynamo can only run in dev mode on Windows. Live reloading is not available on this platform");
        
        global.__dynamoRunningFromIDE = false;
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
    }
    
    
    
    if (__DYNAMO_DEV_MODE)
    {
        __DynamoEnsureNoteDictionary();
        
        global.__dynamoWorkingDirectory = DynamoDevProjectDirectory() + __DYNAMO_SYMLINK_TO_WORKING_DIRECTORY_NAME + "\\";
        __DynamoTrace("Working directory = \"", global.__dynamoWorkingDirectory, "\"");
        
        var _file = file_find_first(global.__dynamoWorkingDirectory + "*.win", 0);
        file_find_close();
        
        if (_file == "")
        {
            __DynamoError("Could not find .win file in working directory. This may mean symlink creation failed.\nPlease run the GameMaker IDE with administrator privileges and try again.");
        }
        else
        {
            __DynamoTrace("Verified .win file is located in working directory");
        }
        
        global.__dynamoFileDictionary = __DynamoDatafilesDictionary(DynamoDevProjectDirectory() + "datafilesDynamo\\", {});
    }
    
    if (DYNAMO_DEV_MODE)
    {
        var _path = "dynamoServerIdent";
        if (os_type == os_android) _path = string_lower(_path);
        
        if (!file_exists(_path))
        {
            __DynamoTrace("Warning! Could not find \"", _path, "\" file in working directory. Please report this error");
        }
        else
        {
            var _buffer = buffer_load(_path);
            var _string = buffer_read(_buffer, buffer_text);
            buffer_delete(_buffer);
            
            _string = string_replace_all(_string, "\n", "");
            _string = string_replace_all(_string, "\r", "");
            
            global.__dynamoCommExpectedServerIdent = _string;
            __DynamoTrace("Found server ident as \"", global.__dynamoCommExpectedServerIdent, "\"");
        }
        
        if (__DYNAMO_ALLOW_NONMATCHING_SERVER) __DynamoTrace("Allowing servers with any ident to connect to this client");
        
        global.__dynamoCommLocal = new __DynamoCommLocalClass(false);
    }
}



function __DynamoTrace()
{
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_debug_message("Dynamo: " + _string);
}

function __DynamoLoud()
{
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_message(_string);
    show_debug_message("Dynamo: Loud: " + _string);
}

function __DynamoError()
{
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_error("Dynamo:\n\n" + _string + "\n ", true);
}

function __DynamoGenerateIdent()
{
    randomize();
    
    var _string = "";
    repeat(20)
    {
        switch(irandom(15)) //TODO - Do this without GM's native PRNG
        {
            case  0: _string += "0"; break;
            case  1: _string += "1"; break;
            case  2: _string += "2"; break;
            case  3: _string += "3"; break;
            case  4: _string += "4"; break;
            case  5: _string += "5"; break;
            case  6: _string += "6"; break;
            case  7: _string += "7"; break;
            case  8: _string += "8"; break;
            case  9: _string += "9"; break;
            case 10: _string += "a"; break;
            case 11: _string += "b"; break;
            case 12: _string += "c"; break;
            case 13: _string += "d"; break;
            case 14: _string += "e"; break;
            case 15: _string += "f"; break;
        }
    }
    
    return _string;
}

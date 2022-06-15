#macro __DYNAMO_VERSION   "2.0.0 alpha 3"
#macro __DYNAMO_DATE      "2022-05-28"
#macro __DYNAMO_DEV_MODE  (DYNAMO_ENABLED && global.__dynamoRunningFromIDE)

#macro __DYNAMO_PROJECT_DIRECTORY_PATH_NAME  "projectDirectory.txt"

__DynamoTrace("Welcome to Dynamo by @jujuadams! This is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE);
global.__dynamoRunningFromIDE = false;



__DynamoInitialize();

function __DynamoInitialize()
{
    if (variable_global_exists("__dynamoProjectDirectory")) return;
    
    //Attempt to set up a time source for slick automatic input handling
    try
    {
        //GMS2022.500.58 runtime
        global.__dynamoTimeSource = time_source_create(time_source_game, 1, time_source_units_frames, function()
        {
            __DynamoAutoUpdate();
        }, [], -1);
        
        time_source_start(global.__dynamoTimeSource);
    }
    catch(_error)
    {
        try
        {
            //Early GMS2022.500.xx runtimes
            global.__dynamoTimeSource = time_source_create(time_source_game, 1, time_source_units_frames, function()
            {
                __DynamoAutoUpdate();
            }, -1);
            
            time_source_start(global.__dynamoTimeSource);
        }
        catch(_error)
        {
            //If the above fails then fall back on needing to call DynamoAutoUpdate()
            global.__dynamoTimeSource = undefined;
            __DynamoTrace("Warning! Running on a GM runtime earlier than 2022.5");
        }
    }
    
    global.__dynamoRunningFromIDE   = __DynamoRunningFromIDE();
    global.__dynamoProjectDirectory = "";
    
    global.__dynamoScriptArray    = [];
    global.__dynamoScriptStruct   = {};
    global.__dynamoFileArray      = [];
    global.__dynamoFileStruct     = {};
    global.__dynamoTrackingArray  = [];
    
    global.__dynamoInFocus    = false;
    global.__dynamoCheckIndex = 0;
    
    if (__DYNAMO_DEV_MODE)
    {
        global.__dynamoProjectDirectory = __DynamoLoadString(__DYNAMO_PROJECT_DIRECTORY_PATH_NAME);
    }
    
    if (global.__dynamoProjectDirectory == "")
    {
        if (__DYNAMO_DEV_MODE)
        {
            __DynamoError("Failed to load \"", __DYNAMO_PROJECT_DIRECTORY_PATH_NAME, "\"\n- You may need to run the GameMaker IDE in administrator mode\n- Ensure that \"pre_run_step.bat\" and \"pre_run_step.sh\" exist in your project's root directory");
        }
        else
        {
            __DynamoTrace("Warning! Failed to load \"", __DYNAMO_PROJECT_DIRECTORY_PATH_NAME, "\"");
        }
    }
    else
    {
        //Clean up the discovered string
        global.__dynamoProjectDirectory = string_replace_all(global.__dynamoProjectDirectory, "\\", "/");
        global.__dynamoProjectDirectory = string_replace_all(global.__dynamoProjectDirectory, "\n", "");
        global.__dynamoProjectDirectory = string_replace_all(global.__dynamoProjectDirectory, "\r", "");
        global.__dynamoProjectDirectory += "/";
        
        if (DYNAMO_VERBOSE) __DynamoTrace("Found project path \"", global.__dynamoProjectDirectory, "\"");
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
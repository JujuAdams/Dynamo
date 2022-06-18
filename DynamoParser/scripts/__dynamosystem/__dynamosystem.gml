#macro __DYNAMO_VERSION   "2.0.0 alpha 3"
#macro __DYNAMO_DATE      "2022-05-28"
#macro __DYNAMO_DEV_MODE  (DYNAMO_ENABLED && global.__dynamoRunningFromIDE)

#macro __DYNAMO_FORCE_DIRECTORY "A:\\GitHub repos\\Mine\\Dynamo\\DynamoExample"

#macro __DYNAMO_PROJECT_DIRECTORY_PATH_NAME  "projectDirectory.txt"

__DynamoTrace("Welcome to Dynamo by @jujuadams! This is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE);
global.__dynamoRunningFromIDE = undefined;


__DynamoInit();

function __DynamoInit()
{
    if (global.__dynamoRunningFromIDE != undefined) return;
    
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
    
    global.__dynamoRunningFromIDE        = __DynamoRunningFromIDE();
    global.__dynamoProjectDirectory      = "";
    global.__dynamoProjectFileSystemName = undefined;
    
    if (!variable_global_exists("__dynamoExpressionDict"     )) global.__dynamoExpressionDict      = {};
    if (!variable_global_exists("__dynamoExpressionFileArray")) global.__dynamoExpressionFileArray = [];
    
    global.__dynamoScriptAuto         = false;
    global.__dynamoScriptAutoApply    = false;
    global.__dynamoScriptAutoCallback = undefined;
    global.__dynamoSoundAuto          = false;
    global.__dynamoSoundAutoCallback  = undefined;
    global.__dynamoFileAuto           = false;
    global.__dynamoFileAutoCallback   = undefined;
    
    global.__dynamoScriptArray    = [];
    global.__dynamoSoundArray     = [];
    global.__dynamoFileArray      = [];
    global.__dynamoTrackingArray  = [];
    global.__dynamoTrackingStruct = {};
    
    global.__dynamoInFocus    = false;
    global.__dynamoCheckIndex = 0;
    
    //Big ol' list of operators. Operators at the top at processed first
    //Not included here are negative signs, negation (! / NOT), and parentheses - these are handled separately
    global.__dynamoExpressionOpList = ["/", "*", "+", "-"];
    
    if (__DYNAMO_DEV_MODE)
    {
        global.__dynamoProjectDirectory = (__DYNAMO_FORCE_DIRECTORY != undefined)? __DYNAMO_FORCE_DIRECTORY : __DynamoLoadString(__DYNAMO_PROJECT_DIRECTORY_PATH_NAME);
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
        global.__dynamoProjectDirectory = string_replace_all(global.__dynamoProjectDirectory, "\n", "");
        global.__dynamoProjectDirectory = string_replace_all(global.__dynamoProjectDirectory, "\r", "");
        
        var _prefix = filename_dir(global.__dynamoProjectDirectory);
        global.__dynamoProjectFileSystemName = string_delete(global.__dynamoProjectDirectory, 1, string_length(_prefix)+1);
        if (DYNAMO_VERBOSE) __DynamoTrace("Project file system name is \"", global.__dynamoProjectFileSystemName, "\"");
        
        //And finally generate the actual project directory string
        //This will be used to orient further file access relative the main .yyp file
        global.__dynamoProjectDirectory += "/";
        if (DYNAMO_VERBOSE) __DynamoTrace("Found project path \"", global.__dynamoProjectDirectory, "\"");
        
        __DynamoExpressionsSetup(global.__dynamoProjectDirectory);
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
    
    if ((global.__dynamoRunningFromIDE == undefined) || __DYNAMO_DEV_MODE) show_message(_string);
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
#macro __DYNAMO_VERSION   "2.0.0 alpha 3"
#macro __DYNAMO_DATE      "2022-05-28"
#macro __DYNAMO_DEV_MODE  (DYNAMO_ENABLED && global.__dynamoRunningFromIDE)

#macro __DYNAMO_FORCE_DIRECTORY "A:\\GitHub repos\\Mine\\Dynamo\\DynamoExample"

#macro __DYNAMO_PROJECT_DIRECTORY_PATH_NAME  "projectDirectory.txt"

#macro __DYNAMO_TYPE_GML     "gml"
#macro __DYNAMO_TYPE_SCRIPT  "script"
#macro __DYNAMO_TYPE_SOUND   "script"
#macro __DYNAMO_TYPE_FILE    "included file"

__DynamoTrace("Welcome to Dynamo by @jujuadams! This is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE);
global.__dynamoRunningFromIDE = undefined;


__DynamoInit();

function __DynamoInit()
{
    if (variable_global_exists("__dynamoProjectJSON")) return;
    
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
    
    global.__dynamoProjectJSON           = {};
    global.__dynamoRunningFromIDE        = __DynamoRunningFromIDE();
    global.__dynamoProjectDirectory      = "";
    global.__dynamoProjectFileSystemName = undefined;
    
    if (!variable_global_exists("__dynamoVariableLookup")) global.__dynamoVariableLookup = {};
    
    global.__dynamoScriptAuto         = false;
    global.__dynamoScriptAutoApply    = false;
    global.__dynamoScriptAutoCallback = undefined;
    global.__dynamoSoundAuto          = false;
    global.__dynamoSoundAutoCallback  = undefined;
    global.__dynamoFileAuto           = false;
    global.__dynamoFileAutoCallback   = undefined;
    
    global.__dynamoGMLArray       = [];
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
        
        __DynamoVariablesParserSetup(global.__dynamoProjectDirectory);
        
        //Load up the project
        global.__dynamoProjectJSON = __DynamoProjectLoad(global.__dynamoProjectDirectory);
        
        if (DYNAMO_DYNAMIC_VARIABLES)
        {
            //Find objects to parse
            var _objectArray = __DynamoProjectFindAssetsByPath(global.__dynamoProjectJSON, global.__dynamoProjectDirectory, "objects", __DynamoClassObject);
            __DynamoAssetArrayFilterByTag(_objectArray, DYNAMO_LIVE_TAG);
            __DynamoAssetArrayFilterRejectByTag(_objectArray, DYNAMO_REJECT_TAG);
            
            //Break down objects into GML files
            var _i = 0;
            repeat(array_length(_objectArray))
            {
                _objectArray[_i].__ConstructGMLContainers();
                ++_i;
            }
            
            //Insert __DynamoVariable() calls into GML whilst also filling out the expression lookup struct
            var _i = 0;
            repeat(array_length(global.__dynamoGMLArray))
            {
                with(global.__dynamoGMLArray[_i])
                {
                    if (__ContentEnsure())
                    {
                        __Apply();
                        __Restore();
                        ++_i;
                    }
                    else
                    {
                        array_delete(global.__dynamoGMLArray, _i, 1);
                    }
                    
                    __CleanUp();
                }
            }
            
            //Save out found expressions to the __DynamoVariableLookupData() script
            __DynamoVariableDataExport(global.__dynamoProjectDirectory);
        }
        
        global.__dynamoScriptArray = __DynamoProjectFindAssetsByPath(global.__dynamoProjectJSON, global.__dynamoProjectDirectory, "scripts", __DynamoClassScript);
        __DynamoAssetArrayFilterByTag(global.__dynamoScriptArray, DYNAMO_TRACK_TAG);
        __DynamoAssetArrayFilterRejectByTag(global.__dynamoScriptArray, DYNAMO_REJECT_TAG);
        
        var _i = 0;
        repeat(array_length(global.__dynamoScriptArray))
        {
            global.__dynamoScriptArray[_i].__Track();
            ++_i;
        }
        
        global.__dynamoSoundArray = __DynamoProjectFindAssetsByPath(global.__dynamoProjectJSON, global.__dynamoProjectDirectory, "sounds", __DynamoClassSound);
        if (DYNAMO_OPT_IN_SOUNDS) __DynamoAssetArrayFilterByTag(global.__dynamoSoundArray, DYNAMO_TRACK_TAG);
        __DynamoAssetArrayFilterRejectByTag(global.__dynamoSoundArray, DYNAMO_REJECT_TAG);
        
        var _i = 0;
        repeat(array_length(global.__dynamoSoundArray))
        {
            global.__dynamoSoundArray[_i].__Track();
            ++_i;
        }
        
        global.__dynamoFileArray = __DynamoProjectFindFiles(global.__dynamoProjectJSON, global.__dynamoProjectDirectory, os_type, os_browser);
        var _i = 0;
        repeat(array_length(global.__dynamoFileArray))
        {
            global.__dynamoFileArray[_i].__Track();
            ++_i;
        }
        
        if (DYNAMO_VERBOSE) __DynamoTrace("Tracking ", global.__dynamoTrackingArray);
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
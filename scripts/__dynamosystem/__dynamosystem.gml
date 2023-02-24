#macro __DYNAMO_VERSION   "2.2.1"
#macro __DYNAMO_DATE      "2022-10-28"
#macro __DYNAMO_DEV_MODE  (DYNAMO_ENABLED && (GM_build_type == "run"))

__DynamoInitialize();

function __DynamoInitialize()
{
    static _initialized = false;
    if (_initialized) return;
    _initialized = true;
    
    __DynamoTrace("Welcome to Dynamo by @jujuadams! This is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE);
    
    var _globalState = __DynamoState();
    
    //Attempt to set up a time source for slick automatic input handling
    time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, __DynamoAutoScan, [], -1));
    
    //Verify the directory just in case
    if (__DYNAMO_DEV_MODE && !directory_exists(_globalState.__projectDirectory))
    {
        __DynamoError("Could not find project directory \"", _globalState.__projectDirectory, "\"\nYou may need to run the GameMaker IDE in administrator mode");
    }
    
    if (DYNAMO_VERBOSE) __DynamoTrace("Found project path \"", _globalState.__projectDirectory, "\"");
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
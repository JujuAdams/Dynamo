// Feather disable all

enum __DYNAMO_GML_TOKEN_STATE
{
    __NULL          = -3,
    __BLOCK_COMMENT = -2,
    __LINE_COMMENT  = -1,
    __UNKNOWN       =  0,
    __IDENTIFIER    =  1,
    __STRING        =  2,
    __NUMBER        =  3,
    __SYMBOL        =  4,
}

#macro __DYNAMO_GML_TOKEN_SYMBOL    0
#macro __DYNAMO_GML_TOKEN_LITERAL   1
#macro __DYNAMO_GML_TOKEN_FUNCTION  2
#macro __DYNAMO_GML_TOKEN_VARIABLE  3

#macro __DYNAMO_GML_OP_NEGATIVE        "__negative__"
#macro __DYNAMO_GML_OP_POSITIVE        "__positive__"
#macro __DYNAMO_GML_OP_TERNARY         "__ternary__"
#macro __DYNAMO_GML_OP_ARRAY_LITERAL   "__arrayLiteral__"
#macro __DYNAMO_GML_OP_STRUCT_LITERAL  "__structLiteral__"

__DynamoInitialize();

function __DynamoInitialize()
{
    static _initialized = false;
    if (_initialized) return;
    _initialized = true;
    
    __DynamoTrace("Welcome to Dynamo by Juju Adams! This is version ", DYNAMO_VERSION, ", ", DYNAMO_DATE);
    
    __DynamoState();
    
    //Verify the directory just in case
    if (DYNAMO_RUNNING)
    {
        if (not directory_exists(DYNAMO_PROJECT_DIRECTORY))
        {
            __DynamoError("Could not find project directory \"", DYNAMO_PROJECT_DIRECTORY, "\"\nYou may need to run the GameMaker IDE in administrator mode");
        }
        
        if (DYNAMO_VERBOSE) __DynamoTrace("Found project path \"", DYNAMO_PROJECT_DIRECTORY, "\"");
        
        //Attempt to set up a time source for slick automatic input handling
        time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, __DynamoAutoScan, [], -1));
    }
}
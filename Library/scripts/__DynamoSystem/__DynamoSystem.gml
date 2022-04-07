#macro __DYNAMO_VERSION    "0.1.0"
#macro __DYNAMO_DATE       "2022-04-07"
#macro __DYNAMO_DEV_MODE   (DYNAMO_DEV_MODE && global.__dynamoRunningFromIDE)

__DynamoTrace("Welcome to Dynamo by @jujuadams! This is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE);



__DynamoInit();

if (DYNAMO_LOAD_MANIFEST_ON_BOOT)
{
    __DynamoTrace("Loading manifest on boot");
    __DynamoEnsureNoteDictionary();
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

function __DynamoNameHash(_name)
{
    return md5_string_utf8(_name);
}

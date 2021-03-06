#macro __DYNAMO_PARSER_VERSION  "2.0"
#macro __DYNAMO_DATE            "2022-06-22"

__DynamoTrace("Welcome to Dynamo by @jujuadams! This is version ", __DYNAMO_PARSER_VERSION, ", ", __DYNAMO_DATE);

global.__dynamoNoteArray = [];

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
#macro __DYNAMO_VERSION         "2.0.0 alpha 3"
#macro __DYNAMO_DATE            "2022-05-28"
#macro __DYNAMO_FORCE_DIRECTORY "A:\\GitHub repos\\Mine\\Dynamo\\DynamoExample"

__DynamoTrace("Welcome to Dynamo by @jujuadams! This is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE);

global.__dynamoExpressionDict      = {};
global.__dynamoExpressionFileArray = [];

//Big ol' list of operators. Operators at the top at processed first
//Not included here are negative signs, negation (! / NOT), and parentheses - these are handled separately
global.__dynamoExpressionOpList = ["/", "*", "+", "-"];

global.__dynamoProjectDirectory = __DYNAMO_FORCE_DIRECTORY;

//Clean up the discovered string
global.__dynamoProjectDirectory = string_replace_all(global.__dynamoProjectDirectory, "\n", "");
global.__dynamoProjectDirectory = string_replace_all(global.__dynamoProjectDirectory, "\r", "");
global.__dynamoProjectDirectory += "/";
    
__DynamoExpressionsSetup(global.__dynamoProjectDirectory);



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
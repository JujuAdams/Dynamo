#macro __DYNAMO_VERSION   "2.0.0 alpha 3"
#macro __DYNAMO_DATE      "2022-05-28"

__DynamoTrace("Welcome to Dynamo by @jujuadams! This is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE);

global.__dynamoExpressionDict      = {};
global.__dynamoExpressionFileArray = [];

//Big ol' list of operators. Operators at the top at processed first
//Not included here are negative signs, negation (! / NOT), and parentheses - these are handled separately
global.__dynamoExpressionOpList = ["/", "*", "+", "-"];



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
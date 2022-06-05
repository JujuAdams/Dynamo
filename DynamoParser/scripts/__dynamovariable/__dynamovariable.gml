/// @param identifier

function __DynamoVariable(_identifier)
{
    if (!variable_struct_exists(global.__dynamoVariableLookup, _identifier))
    {
        __DynamoError("Variable identifier \"", _identifier, "\" not found");
        return undefined;
    }
    
    var _expression = global.__dynamoVariableLookup[$ _identifier];
    
    //Compile this expression if we haven't already
    if (is_string(_expression))
    {
        _expression = __DynamoVariableCompile(_expression);
        global.__dynamoVariableLookup[$ _identifier] = _expression;
    }
    
    if (!is_array(_expression))
    {
        __DynamoError("Variable \"", _identifier, "\" expression failed to compile");
        return undefined;
    }
    
    return __DynamoVariableEvaluate(_expression);
}

function __DynamoVariableEvaluate(_expression)
{
    
}
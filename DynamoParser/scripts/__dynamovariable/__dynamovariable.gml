/// @param identifier

function __DynamoVariable(_identifier)
{
    if (!variable_struct_exists(global.__dynamoVariableLookup, _identifier))
    {
        __DynamoError("Variable identifier \"", _identifier, "\" not found");
        return undefined;
    }
    
    return __DynamoExpressionEvaluate(self, global.__dynamoVariableLookup[$ _identifier]);
}
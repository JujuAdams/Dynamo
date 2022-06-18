/// @param identifier

function __DynamoExpression(_identifier)
{
    if (!variable_struct_exists(global.__dynamoExpressionDict, _identifier))
    {
        __DynamoError("Variable identifier \"", _identifier, "\" not found");
        return undefined;
    }
    
    return __DynamoExpressionEvaluate(self, global.__dynamoExpressionDict[$ _identifier]);
}
// Feather disable all

/// @param variableName
/// @param value

function DynamoScriptEnvSetVariable(_variable, _value)
{
    static _globalVariableStruct = __DynamoState().__globalVariableStruct;
    
    _globalVariableStruct[$ _variable] = method(
    {
        __value: _value,
    },
    function()
    {
        return __value;
    });
}
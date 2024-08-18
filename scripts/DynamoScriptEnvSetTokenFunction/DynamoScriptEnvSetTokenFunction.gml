// Feather disable all

/// Adds a token to all future script updates. When evaluated, the token will execute the defined
/// function. The return value from that function will be used as the value for the token. This is
/// useful for dynamically updating values (time, mouse position and so on). The `metadata`
/// parameter is passed as the one (and only) parameter for the defined function.
/// 
/// @param tokenName
/// @param function
/// @param [metadata=undefined]

function DynamoScriptEnvSetTokenFunction(_token, _function, _metadata = undefined)
{
    static _globalTokenStruct = __DynamoState().__globalTokenStruct;
    
    _globalTokenStruct[$ _token] = method(
    {
        __function: _function,
        __metadata: _metadata,
    },
    function()
    {
        return __function(__metadata);
    });
}
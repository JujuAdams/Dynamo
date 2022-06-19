/// @param name
/// @param path
/// @param hash

function __DynamoExpressionFileWatch(_name, _variablePrefix, _path, _hash)
{
    var _adjustedPath = string_replace_all(_path, "\\", "/");
    if (!file_exists(global.__dynamoProjectDirectory + _adjustedPath))
    {
        __DynamoTrace("Warning! File \"", global.__dynamoProjectDirectory, _adjustedPath, "\" not found");
    }
    
    if (variable_struct_exists(global.__dynamoExpressionFileStruct, _name)) __DynamoError("File \"", _adjustedPath, "\" is already being watched");
    
    var _watcher = new __DynamoClassExpressionFile(_name, _variablePrefix, global.__dynamoProjectDirectory, _adjustedPath, _hash);
}
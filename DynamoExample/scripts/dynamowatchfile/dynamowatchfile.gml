/// <dataFormat> can be:
///    "json"
///    "csv"
///    "string"
///    "buffer"
/// 
/// @param path
/// @param dataFormat
/// @param callback

function DynamoWatchFile(_path, _dataFormat, _callback)
{
    __DynamoInitialize();
    
    var _adjustedPath = string_replace_all(_path, "\\", "/");
    if (!file_exists(global.__dynamoProjectDirectory + "datafiles/" + _adjustedPath))
    {
        __DynamoTrace("Warning! File \"", global.__dynamoProjectDirectory + "datafiles/" + _path, "\" not found");
    }
    
    _dataFormat = string_lower(_dataFormat);
    switch(_dataFormat)
    {
        case "json":
        case "csv":
        case "string":
        case "buffer":
        break;
        
        default:
            __DynamoError("Illegal data format provided (", _dataFormat, ")\nData format must be \"json\", \"csv\", \"text\", or \"binary\"");
        break;
    }
    
    if (is_numeric(_callback))
    {
        if (!script_exists(_callback)) __DynamoError("Callback script with index ", _callback, " doesn't exist");
    }
    else if (!is_method(_callback))
    {
        __DynamoError("Illegal datatype passed for the callback (was ", typeof(_callback), ")");
    }
    
    if (variable_struct_exists(global.__dynamoScriptStruct, _path)) __DynamoError("File \"", _path, "\" is already being watched");
    
    var _watcher = new __DynamoClassFile(_path, global.__dynamoProjectDirectory + "datafiles/", _adjustedPath);
    _watcher.__dataFormat = _dataFormat;
    _watcher.__callback   = _callback;
}
/// @param name
/// @param dataFormat
/// @param callback

function DynamoNoteWatch(_note, _dataFormat, _callback)
{
    __DynamoInitialize();
    
    if (!variable_struct_exists(global.__dynamoNoteStruct, _note))
    {
        __DynamoError("Note \"", _note, "\" not found");
    }
    
    if (variable_struct_exists(global.__dynamoNoteAddedStruct, _note))
    {
        __DynamoError("Watcher for note \"", _note, "\" already created");
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
    
    var _watcher = global.__dynamoNoteStruct[$ _note];
    _watcher.__dataFormat = _dataFormat;
    _watcher.__callback   = _callback;
    
    global.__dynamoNoteAddedStruct[$ _note] = true;
}
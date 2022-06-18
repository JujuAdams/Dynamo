function __DynamoPrepareObject(_name, _relativeDirectory, _absoluteDirectory, _yyFilename)
{
    var _yyPath = _absoluteDirectory + _yyFilename;
    if (!file_exists(_yyPath)) __DynamoError("Could not find \"", _yyPath, "\"");
    
    var _buffer = buffer_load(_yyPath);
    var _string = buffer_read(_buffer, buffer_text);
    buffer_delete(_buffer);
    
    var _yyJSON = json_parse(_string);
    var _eventArray = _yyJSON.eventList;
    
    var _i = 0;
    repeat(array_length(_eventArray))
    {
        var _eventStruct = _eventArray[_i];
        var _eventName = __DynamoEventFilename(_eventStruct.eventType, _eventStruct.eventNum);
        var _relativePath = _relativeDirectory + _eventName + ".gml";
        var _absolutePath = _absoluteDirectory + _eventName + ".gml";
        __DynamoPrepareGMLFile(_name + " " + _eventName, _relativePath, _absolutePath, "__Dynamo_" + _name + "_" + _eventName + "_var");
        ++_i;
    }
}
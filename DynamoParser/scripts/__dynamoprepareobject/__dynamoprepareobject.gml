function __DynamoPrepareObject(_name, _directory, _yyFilename)
{
    var _yyPath = _directory + _yyFilename;
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
        var _path = _directory + _eventName + ".gml";
        __DynamoPrepareGMLFile(_name + " " + _eventName, _path, "__Dynamo_" + _name + "_" + _eventName + "_var");
        ++_i;
    }
}

 function __DynamoEventFilename(_eventType, _eventNumber)
 {
     var _string = undefined;
     
     switch(_eventType)
     {
         case 0: _string = "Create"; break;
         case 3: _string = "Step";   break;
         case 8: _string = "Draw";   break;
         
         default:
            __DynamoError("Did not recognise event type ", _eventType);
         break;
     }
     
     return _string + "_" + string(_eventNumber);
 }
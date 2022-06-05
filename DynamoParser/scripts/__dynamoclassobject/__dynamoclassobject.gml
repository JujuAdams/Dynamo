function __DynamoClassObject(_path) constructor
{
    __path = _path;
    
    __metadataStub = true;
    __metadataHash = undefined;
    
    __json = {};
    
    static __MakeGML = function()
    {
        if (!is_struct(__json)) return;
        
        var _object     = __json.name;
        var _eventArray = __json.eventList;
        
        if (DYNAMO_VERBOSE) __DynamoTrace("Parsing ", _object, ", it has ", array_length(_eventArray), " events");
        
        var _i = 0;
        repeat(array_length(_eventArray))
        {
            var _eventStruct = _eventArray[_i];
            var _eventNum  = _eventStruct.eventNum;
            var _eventType = _eventStruct.eventType;
            
            var _filename = undefined;
            switch(_eventType)
            {
                case 8: _filename = "Draw_" + string(_eventNum); break;
                
                default: __DynamoError("Event type ", _eventType, " unhandled"); break;
            }
            
            var _path = filename_dir(__path) + "/" + _filename + ".gml";
            var _gml = new __DynamoClassGML(_path, _object, _eventType, _eventNum);
            array_push(global.__dynamoGMLArray, _gml);
            
            if (DYNAMO_VERBOSE) __DynamoTrace("Added \"", _path, "\"");
            _gml.__Apply();
            
            ++_i;
        }
    }
    
    static __Track = function()
    {
        if (!__MetadataEnsure()) return;
        
        var _name = __GetName();
        array_push(global.__dynamoTrackingArray, _name);
        global.__dynamoTrackingStruct[$ _name] = self;
    }
    
    static __MetadataEnsure = function(_dontCheckHash = true)
    {
        var _foundHash = (_dontCheckHash && (__metadataHash != undefined) && !__metadataStub)? __metadataHash : __DynamoFileHash(__path);
        if (_foundHash != __metadataHash)
        {
            __metadataHash = _foundHash;
            
            __json = __DynamoLoadJSON(__path, undefined);
            if (is_struct(__json)) __metadataStub = false;
        }
        
        return is_struct(__json);
    }
    
    static __TagAnyMatches = function(_tag)
    {
        if (!__MetadataEnsure()) return false;
        
        var _tagArray = __json.tags;
        var _i = 0;
        repeat(array_length(_tagArray))
        {
            if (_tagArray[_i] == _tag) return true;
            ++_i;
        }
        
        return false;
    }
    
    static __GetName = function()
    {
        if (!__MetadataEnsure()) return "<unknown object>";
        return __json.name;
    }
    
    static toString = function()
    {
        return __GetName();
    }
}
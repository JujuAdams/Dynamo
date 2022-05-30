function __DynamoClassGML(_path, _object, _eventType, _eventNum) constructor
{
    static __type = __DYNAMO_TYPE_GML;
    
    __object    = _object;
    __eventType = _eventType;
    __eventNum  = _eventNum;
    
    __contentStub = true;
    __contentPath = _path;
    __contentHash = undefined;
    
    static __Setup = function()
    {
        __contentStub = false;
        __contentHash = __DynamoFileHash(__contentPath);
        
        var _inBuffer = buffer_load(__contentPath);
        
        __DynamoParseGML(_inBuffer);
        
        if (true) buffer_save(_inBuffer, __contentPath);
        buffer_delete(_inBuffer);
    }
}
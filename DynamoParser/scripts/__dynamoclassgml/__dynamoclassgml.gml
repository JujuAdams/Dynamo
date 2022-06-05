function __DynamoClassGML(_path, _object, _eventType, _eventNum) constructor
{
    static __type = __DYNAMO_TYPE_GML;
    
    __object         = _object;
    __eventType      = _eventType;
    __eventNum       = _eventNum;
    __eventSignature = string(__object) + "_t" + string(__eventType) + "_n" + string(__eventNum);
    
    __contentStub = true;
    __contentPath = _path;
    __contentHash = undefined;
    
    __contentParserData = undefined;
    
    static __Apply = function()
    {
        __contentStub = false;
        __contentHash = __DynamoFileHash(__contentPath);
        
        //Load the base content and immediately save a backup
        var _inBuffer = buffer_load(__contentPath);
        buffer_save(_inBuffer, __eventSignature + ".gml");
        
        //Parse the content into variable targets
        __contentParserData = __DynamoParseGML(_inBuffer);
        
        //Set up a batched buffer operation so we can modify the source GML
        //This handles the annoying offset calculations for us
        var _batchOp = new __DynamoBufferBatch();
        _batchOp.FromBuffer(_inBuffer);
        
        var _i = 0;
        repeat(array_length(__contentParserData))
        {
            with(__contentParserData[_i])
            {
                var _variableIdentifier = "__Dynamo_" + other.__eventSignature + "_var" + string(_i);
                
                //Insert the function call to __DynamoVariable() with the variable identifier whilst also commenting out the original expression
                _batchOp.Insert(startPos, "__DynamoVariable(\"", _variableIdentifier, "\") /*");
                _batchOp.Insert(endPos+1, "*/");
                
                //Add the variable identifier and token information to our global handler
                global.__dynamoVariableLookup[$ _variableIdentifier] = innerString;
            }
            
            ++_i;
        }
        
        //Commit the batch operation and return a buffer, then immediately save it out to disk
        buffer_save(_batchOp.GetBuffer(), __contentPath);
        
        _batchOp.Destroy();
    }
}
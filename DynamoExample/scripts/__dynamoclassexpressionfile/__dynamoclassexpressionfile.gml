function __DynamoClassExpressionFile(_name, _variablePrefix, _directory, _localPath, _hash) constructor
{
    __name = _name;
    __path = _directory + _localPath;
    
    array_push(global.__dynamoExpressionFileArray, self);
    global.__dynamoExpressionFileStruct[$ __name] = self;
    array_push(global.__dynamoTrackingArray, self);
    
    __variablePrefix = _variablePrefix;
    __hash = _hash;
    
    
    
    static toString = function()
    {
        return __name;
    }
    
    static __HasChanged = function()
    {
        if (!DYNAMO_ENABLED || !DYNAMO_EXPRESSIONS_ENABLED) return false;
        return (__DynamoFileHash(__path) != __hash);
    }
    
    static __Load = function()
    {
        if (!DYNAMO_ENABLED || !DYNAMO_EXPRESSIONS_ENABLED) return;
        
        __hash = __DynamoFileHash(__path);
        var _buffer = __DynamoLoadBuffer(__path);
        
        if (_buffer != undefined)
        {
            var _parserData = __DynamoExtractExpressions(_buffer);
            var _i = 0;
            repeat(array_length(_parserData))
            {
                var _variableIdentifier = __variablePrefix + string(_i);
                global.__dynamoExpressionDict[$ _variableIdentifier] = __DynamoExpressionCompile(_parserData[_i].innerString);
                ++_i;
            }
        }
        
        if (_buffer != undefined) buffer_delete(_buffer);
    }
}
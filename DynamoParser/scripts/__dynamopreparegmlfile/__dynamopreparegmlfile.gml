function __DynamoPrepareGMLFile(_name, _path, _variablePrefix)
{
    if (!file_exists(_path)) __DynamoError("Could not find \"", _path, "\"");
    
    var _contentBuffer = buffer_load(_path);
    var _parserData = __DynamoParseGML(_contentBuffer);
    
    //Don't do anything if there're no Dynamo variables in this GML file
    if (array_length(_parserData) <= 0)
    {
        buffer_delete(_contentBuffer);
        return;
    }
    
    //Otherwise we're gonna get our hands dirty, make a backup
    __DynamoRegisterBackup(_name, _path);
    
    //Set up a batched buffer operation so we can modify the source GML
    //This handles the annoying offset calculations for us
    var _batchOp = new __DynamoBufferBatch();
    _batchOp.FromBuffer(_contentBuffer);
    
    var _i = 0;
    repeat(array_length(_parserData))
    {
        with(_parserData[_i])
        {
            var _variableIdentifier = _variablePrefix + string(_i);
                
            //Insert the function call to __DynamoVariable() with the variable identifier whilst also commenting out the original expression
            _batchOp.Insert(startPos, "__DynamoVariable(\"", _variableIdentifier, "\") /*");
            _batchOp.Insert(endPos+1, "*/");
                
            //Add the variable identifier and token information to our global handler
            global.__dynamoExpressionFoundDict[$ _variableIdentifier] = innerString;
        }
            
        ++_i;
    }
    
    //Commit the batch operation and return a buffer, then immediately save it out to disk
    buffer_save(_batchOp.GetBuffer(), _path);
    _batchOp.Destroy();
    
    array_push(global.__dynamoExpressionFileArray, _path);
}
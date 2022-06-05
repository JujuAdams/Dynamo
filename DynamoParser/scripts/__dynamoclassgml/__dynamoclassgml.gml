function __DynamoClassGML(_absolutePath, _relativePath, _object, _eventType, _eventNum) constructor
{
    static __type = __DYNAMO_TYPE_GML;
    
    __object         = _object;
    __eventType      = _eventType;
    __eventNum       = _eventNum;
    __eventSignature = string(__object) + "_t" + string(__eventType) + "_n" + string(__eventNum);
    
    __contentStub         = true;
    __contentHash         = undefined;
    __contentAbsolutePath = _absolutePath;
    __contentRelativePath = _relativePath;
    __contentBuffer       = undefined;
    
    __contentParserData = undefined;
    
    __backupPath = __contentAbsolutePath + "_backup";
    
    static __CleanUp = function()
    {
        if (__contentBuffer != undefined)
        {
            buffer_delete(__contentBuffer);
            __contentBuffer = undefined;
        }
        
        __contentHash = undefined;
    }
    
    static __ContentEnsure = function()
    {
        if (__contentHash == undefined)
        {
            __contentStub = false;
            __contentHash = __DynamoFileHash(__contentAbsolutePath);
            
            //Load the base content and immediately save a backup
            if (__contentBuffer != undefined) buffer_delete(__contentBuffer);
            __contentBuffer = buffer_load(__contentAbsolutePath);
            
            //Parse the content into variable targets
            __contentParserData = __DynamoParseGML(__contentBuffer);
        }
        
        return (is_array(__contentParserData) && (array_length(__contentParserData) > 0));
    }
    
    static __Apply = function()
    {
        if (!__ContentEnsure()) return;
        
        //Don't do anything if there're no Dynamo variables in this GML file
        if (array_length(__contentParserData) <= 0) return;
        
        //Make a backup
        file_delete(__backupPath);
        file_copy(__contentAbsolutePath, __backupPath);
        if (!file_exists(__backupPath)) __DynamoError("Could not save backup \"", __backupPath, "\"");
        
        //Set up a batched buffer operation so we can modify the source GML
        //This handles the annoying offset calculations for us
        var _batchOp = new __DynamoBufferBatch();
        _batchOp.CopyFromBuffer(__contentBuffer);
        
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
        buffer_save(_batchOp.GetBuffer(), __contentAbsolutePath);
         
        _batchOp.Destroy();
    }
    
    static __UpdateInternal = function()
    {
        if (!__ContentEnsure()) return;
        
        //Don't do anything if there're no Dynamo variables in this GML file
        if (array_length(__contentParserData) <= 0) return;
        
        var _i = 0;
        repeat(array_length(__contentParserData))
        {
            with(__contentParserData[_i])
            {
                var _variableIdentifier = "__Dynamo_" + other.__eventSignature + "_var" + string(_i);
                global.__dynamoVariableLookup[$ _variableIdentifier] = __DynamoExpressionCompile(innerString);
            }
            
            ++_i;
        }
    }
    
    static __Restore = function()
    {
        //Don't do anything if there's no backup to restore
        if (!file_exists(__backupPath)) return;
        
        file_copy(__backupPath, __contentAbsolutePath);
        if (__DynamoFileHash(__contentAbsolutePath) != __DynamoFileHash(__backupPath)) __DynamoError("Failed to restore backup \"", __backupPath, "\"");
        
        file_delete(__backupPath);
    }
}
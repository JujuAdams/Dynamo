function DynamoGetChangedAssets()
{
    static _scriptArray = [];
    static _fileArray = [];
    
    static _return = {
        scripts: _scriptArray,
        files: _fileArray,
    };
    
    var _i = 0;
    repeat(array_length(global.__dynamoScriptArray))
    {
        if (global.__dynamoScriptArray[_i].__HasChanged()) array_push(_scriptArray, global.__dynamoScriptArray[_i]);
        ++_i;
    }
    
    var _i = 0;
    repeat(array_length(global.__dynamoFileArray))
    {
        if (global.__dynamoFileArray[_i].__HasChanged()) array_push(_fileArray, global.__dynamoFileArray[_i]);
        ++_i;
    }
   
    return _return;
}
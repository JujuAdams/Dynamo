/// Returns a struct that contains four arrays. These arrays will contain which assets have changed,
/// be it names of scripts, notes, Included File paths, or object event names, as appropriate.

function DynamoGetChangedAssets()
{
    static _scriptArray         = [];
    static _fileArray           = [];
    static _noteArray           = [];
    static _expressionFileArray = [];
    
    static _return = {
        scripts:         _scriptArray,
        files:           _fileArray,
        notes:           _noteArray,
        expressionFiles: _expressionFileArray,
    };
    
    array_resize(_scriptArray, 0);
    array_resize(_fileArray, 0);
    
    var _i = 0;
    repeat(array_length(global.__dynamoScriptArray))
    {
        if (global.__dynamoScriptArray[_i].__HasChanged()) array_push(_scriptArray, string(global.__dynamoScriptArray[_i]));
        ++_i;
    }
    
    var _i = 0;
    repeat(array_length(global.__dynamoFileArray))
    {
        if (global.__dynamoFileArray[_i].__HasChanged()) array_push(_fileArray, string(global.__dynamoFileArray[_i]));
        ++_i;
    }
    
    var _i = 0;
    repeat(array_length(global.__dynamoNoteArray))
    {
        if (global.__dynamoNoteArray[_i].__HasChanged()) array_push(_noteArray, string(global.__dynamoNoteArray[_i]));
        ++_i;
    }
    
    var _i = 0;
    repeat(array_length(global.__dynamoExpressionFileArray))
    {
        if (global.__dynamoExpressionFileArray[_i].__HasChanged()) array_push(_expressionFileArray, string(global.__dynamoExpressionFileArray[_i]));
        ++_i;
    }
   
    return _return;
}
/// Forces Dynamo to scan all watched assets (scripts and Included Files). Any assets
/// that have changed will be reloaded. If DYNAMO_AUTO_SCAN is set to <true> then you don't
/// need to call this function as Dynamo will constantly scan assets for you.

function DynamoForceScan()
{
    if (!__DYNAMO_DEV_MODE) return undefined;
    
    static _fileArray   = __DynamoState().__fileArray;
    static _scriptArray = __DynamoState().__scriptArray;
    
    var _i = 0;
    repeat(array_length(_scriptArray))
    {
        if (_scriptArray[_i].__HasChanged()) _scriptArray[_i].__Load();
        ++_i;
    }
    
    var _i = 0;
    repeat(array_length(_fileArray))
    {
        if (_fileArray[_i].__HasChanged()) _fileArray[_i].__Load();
        ++_i;
    }
}
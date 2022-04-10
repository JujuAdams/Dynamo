/// Checks for changes to Note assets in your project directory
/// 
///   N.B. You should *NOT* call this function every frame as it is slow and will cause significant
///        performance issues. Instead, consider using DynamoDevCheckForChangesOnRefocus() or call
///        this function on a keypress (such as F5)
/// 
/// Returns an array containing the names of Notes that have changed. If no Notes have changed then
/// this function returns <undefined>
/// 
/// This function is only avaiable when running from the IDE and if DYNAMO_DEV_MODE is set to <true>

function DynamoDevCheckForChanges()
{
    //Guarantee we're initialized
    __DynamoInit();
    
    //Though if we're not in dev mode then ignore this function
    //(This macro is set to <false> if we're not running from the IDE as well)
    if (!__DYNAMO_DEV_MODE) return undefined;
    
    __DynamoEnsureNoteDictionary();
    
    var _output = undefined;
    _output = __DynamoCheckForNoteChanges(_output, global.__dynamoProjectDirectory, global.__dynamoWorkingDirectory);
    _output = __DynamoCheckForDatafilesChanges(_output, global.__dynamoProjectDirectory, global.__dynamoWorkingDirectory);
    
    return _output;
}
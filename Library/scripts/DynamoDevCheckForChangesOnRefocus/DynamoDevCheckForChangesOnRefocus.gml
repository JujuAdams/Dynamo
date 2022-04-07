/// Checks for changes to Note assets in your project directory when the game is refocused by the player/// 
///   N.B. You should call this function every frame in a controller instance of some sort
/// 
/// Returns an array containing the names of Notes that have changed. If no Notes have changed then this
/// function returns <undefined>. If the game has not been refocused then this function returns <undefined>
/// 
/// This function is only avaiable when running from the IDE and if DYNAMO_DEV_MODE is set to <true>

function DynamoDevCheckForChangesOnRefocus()
{
    __DynamoInit();
    
    //Though if we're not in dev mode then ignore this function
    //(This macro is set to <false> if we're not running from the IDE as well)
    if (!__DYNAMO_DEV_MODE) return undefined;
    
    //Track whether the window focus has changed
    var _focus = window_has_focus();
    if (global.__dynamoInFocus != _focus)
    {
        global.__dynamoInFocus = _focus;
        
        //If the focus *has* changed and we're now in focus then check for changes
        if (_focus) return DynamoDevCheckForChanges();
    }
    
    return undefined;
}

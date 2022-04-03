function DynamoDevCheckForChangesOnFocus()
{
    if (__DYNAMO_DEV_MODE)
    {
        var _focus = window_has_focus();
        if (global.__dynamoInFocus != _focus)
        {
            global.__dynamoInFocus = _focus;
            if (_focus) return DynamoDevCheckForChanges();
        }
    }
    
    return undefined;
}

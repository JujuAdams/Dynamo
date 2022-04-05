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
    if (!__DYNAMO_DEV_MODE) return undefined;
    
    __DynamoEnsureManifest();
    
    var _output = undefined;
    
    var _nameHashArray = variable_struct_get_names(global.__dynamoManifestDictionary);
    var _i = 0;
    repeat(array_length(_nameHashArray))
    {
        var _note = global.__dynamoManifestDictionary[$ _nameHashArray[_i]];
        if (_note.__CheckForChange())
        {
            if (!is_array(_output)) _output = [];
            array_push(_output, _note.__name);
        }
        
        ++_i;
    }
    
    return _output;
}
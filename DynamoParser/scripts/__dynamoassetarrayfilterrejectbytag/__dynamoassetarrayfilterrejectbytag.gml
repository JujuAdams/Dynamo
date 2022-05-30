/// @param array
/// @param tag

function __DynamoAssetArrayFilterRejectByTag(_array, _tag)
{
    if (!__DYNAMO_DEV_MODE) return;
    
    var _count = 0;
    
    var _i = 0;
    repeat(array_length(_array))
    {
        with(_array[_i])
        {
            __MetadataEnsure(false);
            
            if (__TagAnyMatches(_tag))
            {
                ++_count;
                array_delete(_array, _i, 1);
            }
            else
            {
                ++_i;
            }
        }
    }
    
    if (DYNAMO_VERBOSE) __DynamoTrace("Removed ", _count, " assets with tag \"", _tag, "\"");
}
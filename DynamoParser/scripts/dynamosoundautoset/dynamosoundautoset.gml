/// @param state
/// @param callback

function DynamoSoundAutoSet(_state, _callback)
{
    __DynamoInit();
    if (!__DYNAMO_DEV_MODE) return;
    
    if (_callback != undefined)
    {
        if (!is_method(_callback))
        {
            if (!is_numeric(_callback))
            {
                __DynamoError("Invalid callback (typeof=", typeof(_callback), ")");
            }
            else if (!script_exists(_callback))
            {
                __DynamoError("Script ", _callback, " doesn't exist");
            }
        }
    }
    
    global.__dynamoSoundAuto         = _state;
    global.__dynamoSoundAutoCallback = _callback;
}
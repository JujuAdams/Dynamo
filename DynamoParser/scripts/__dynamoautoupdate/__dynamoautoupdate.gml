function __DynamoAutoUpdate()
{
    if (!__DYNAMO_DEV_MODE) return undefined;
    
    if (!DYNAMO_PROGRESSIVE_SCAN && (os_type == os_windows))
    {
        //Track whether the window focus has changed
        var _focus = window_has_focus();
        
        if (global.__dynamoInFocus != _focus)
        {
            global.__dynamoInFocus = _focus;
        
            //If the focus *has* changed and we're now in focus then check for changes
            if (_focus) return __DynamoDoUpdate();
        }
    }
    else if (DYNAMO_PROGRESSIVE_SCAN || (os_type == os_macosx))
    {
        if (!global.__dynamoScriptAuto && !global.__dynamoFileAuto)
        {
            //If no automatic checking is set up, don't bother doing a progressive scan
            return;
        }
        
        //We have to use progressive scanning on Mac because YoYoGames are idiots and can't make a simple function like window_has_focus() work
        var _count = array_length(global.__dynamoTrackingArray);
        if (_count <= 0) return;
        global.__dynamoCheckIndex = (global.__dynamoCheckIndex + 1) mod _count;
        
		var _assetName = global.__dynamoTrackingArray[global.__dynamoCheckIndex];
        if (global.__dynamoTrackingStruct[$ _assetName].__ContentCheckForChanges())
        {
            if (DYNAMO_VERBOSE) __DynamoTrace("Change found in \"", _assetName, "\"");
            return __DynamoDoUpdate();
        }
    }
    
    return undefined;
}

function __DynamoDoUpdate()
{
    if (!__DYNAMO_DEV_MODE) return undefined;
    
    if (global.__dynamoScriptAuto)
    {
        if (global.__dynamoScriptAutoApply)
        {
            if (DYNAMO_VERBOSE) __DynamoTrace("Automatically checking all tracked scripts and applying any changes");
        }
        else
        {
            if (DYNAMO_VERBOSE) __DynamoTrace("Automatically checking all tracked scripts for changes (not applying changes)");
        }
        
        var _result = undefined;
        var _i = 0;
        repeat(array_length(global.__dynamoScriptArray))
        {
            var _assetName = global.__dynamoScriptArray[_i];
            if (DynamoAssetChanged(_assetName))
            {
                if (!is_array(_result)) _result = [];
                array_push(_result, _assetName);
                if (global.__dynamoScriptAutoApply) DynamoScriptApply(_assetName);
            }
            
            ++_i;
        }
        
        if (is_array(_result) && (global.__dynamoScriptAutoCallback != undefined))
        {
            if (is_method(global.__dynamoScriptAutoCallback))
            {
                global.__dynamoScriptAutoCallback(_result);
            }
            else if (is_numeric(global.__dynamoScriptAutoCallback))
            {
                script_execute(global.__dynamoScriptAutoCallback, _result);
            }
        }
    }
    
    if (global.__dynamoSoundAuto)
    {
        if (DYNAMO_VERBOSE) __DynamoTrace("Automatically checking all tracked sounds for changes");
        
        var _result = undefined;
        var _i = 0;
        repeat(array_length(global.__dynamoSoundArray))
        {
            var _assetName = global.__dynamoSoundArray[_i];
            if (DynamoAssetChanged(_assetName))
            {
                if (!is_array(_result)) _result = [];
                array_push(_result, _assetName);
                global.__dynamoTrackingStruct[$ _assetName].__Apply();
            }
            
            ++_i;
        }
        
        if (is_array(_result) && (global.__dynamoSoundAutoCallback != undefined))
        {
            if (is_method(global.__dynamoSoundAutoCallback))
            {
                global.__dynamoSoundAutoCallback(_result);
            }
            else if (is_numeric(global.__dynamoSoundAutoCallback))
            {
                script_execute(global.__dynamoSoundAutoCallback, _result);
            }
        }
    }
    
    if (global.__dynamoFileAuto)
    {
        if (DYNAMO_VERBOSE) __DynamoTrace("Automatically checking all tracked included files for changes");
        
        var _result = undefined;
        var _i = 0;
        repeat(array_length(global.__dynamoFileArray))
        {
            var _assetName = global.__dynamoFileArray[_i];
            if (DynamoAssetChanged(_assetName))
            {
                if (!is_array(_result)) _result = [];
                array_push(_result, _assetName);
            }
            
            ++_i;
        }
        
        if (is_array(_result) && (global.__dynamoFileAutoCallback != undefined))
        {
            if (is_method(global.__dynamoFileAutoCallback))
            {
                global.__dynamoFileAutoCallback(_result);
            }
            else if (is_numeric(global.__dynamoFileAutoCallback))
            {
                script_execute(global.__dynamoFileAutoCallback, _result);
            }
        }
    }
}
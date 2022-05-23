if (os_type != os_windows)
{
    __DynamoLoud("Dynamo is not currently supported on this OS.");
    game_end();
    return;
}

if (global.__dynamoRunningFromIDE)
{
    __DynamoTrace("Running from IDE");
    
    if (true)
    {
        //var _instance = instance_create_layer(0, 0, layer, oInstall);
        //_instance.directory = "A:\\GitHub repos\\Mine\\Dynamo\\Example Project\\";
        
        instance_create_layer(0, 0, layer, oServer);
    }
}
else
{
    if (parameter_string(1) == "-selfextracting")
    {
        __DynamoTrace("Running from self-extracting installer");
        
        //Clean up the weird broken parameter string that we might get passed
        var _i = 2;
        var _parameterString = "";
        repeat(parameter_count() - _i)
        {
            _parameterString += parameter_string(_i) + " ";
            ++_i;
        }
        
        if (parameter_count() > 2)
        {
            _parameterString = string_copy(_parameterString, 1, string_length(_parameterString)-1);
        }
    }
    else
    {
        __DynamoTrace("Running from executable");
        
        var _i = 0;
        var _parameterString = "";
        repeat(parameter_count() - _i)
        {
            _parameterString += parameter_string(_i) + " ";
            ++_i;
        }
        
        if (parameter_count() > 0)
        {
            _parameterString = string_copy(_parameterString, 1, string_length(_parameterString)-1);
        }
    }
    
    __DynamoTrace("Parameter string is \"", _parameterString, "\"");
    
    var _pos = string_pos("-export", _parameterString);
    if (_pos > 0)
    {
        var _projectDirectory = filename_dir(string_copy(_parameterString, 1, _pos-1)) + "\\";
        var _exportDirectory  = string_delete(_parameterString, 1, _pos + string_length("-export"));
        
        __DynamoTrace("Exporting Notes from project in \"", _projectDirectory, "\" to \"", _exportDirectory, "\"");
        __DynamoCheckForNoteChanges(undefined, _projectDirectory, _exportDirectory);
        
        //Done!
        __DynamoTrace("Export complete");
        
        game_end();
        return;
    }
    
    instance_create_layer(0, 0, layer, oServer);
    return;
    
    var _pos = string_pos("-server", _parameterString);
    if (_pos > 0)
    {
        var _expectedServerIdent = string_delete(_parameterString, 1, _pos + string_length("-server"));
        var _spacePos = string_pos(" ", _expectedServerIdent);
        _expectedServerIdent = string_copy(_expectedServerIdent, 1, _spacePos - 1);
        
        global.__dynamoCommExpectedServerIdent = _expectedServerIdent;
        __DynamoTrace("Extracted server ident from executable parameters (", global.__dynamoCommExpectedServerIdent, ")");
        
        instance_create_layer(0, 0, layer, oServer);
        return;
    }
    
    //No -export, let's try to setup!
    var _instance = instance_create_layer(0, 0, layer, oInstall);
    _instance.directory = filename_dir(_parameterString) + "\\";
}

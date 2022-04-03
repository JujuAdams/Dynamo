function __DynamoInstall(_directory)
{
    if (!__DynamoQuestion("Would you like to attach Dynamo to the project in this directory?\n\n", _directory)) return;
    
    __DynamoTrace("Installing Dynamo to ", _directory);
    
    var _projectJSON = __DynamoMainProjectJSON(_directory);
    if (_projectJSON == undefined)
    {
        __DynamoTrace("Failed to verify main project file");
        return;
    }
    
    __DynamoTrace("Main project file verified, installing Dynamo build script");
    
    var _commandString = "\"%YYprojectDir%\\dynamo.exe\" -compile";
    var _buildScriptAlreadyExists = false;
    
    var _buildScriptPath = _directory + "pre_build_step.bat";
    if (!file_exists(_buildScriptPath))
    {
        __DynamoTrace("Pre-build batch file not found \"", _buildScriptPath, "\", creating one");
        var _buildScriptBuffer = buffer_create(1024, buffer_grow, 1);
        
        buffer_write(_buildScriptBuffer, buffer_text, _commandString);
    }
    else
    {
        __DynamoTrace("Pre-build batch file found \"", _buildScriptPath, "\"");
        
        try
        {
            var _buildScriptBuffer = buffer_load(_buildScriptPath);
            var _buildScriptString = buffer_read(_buildScriptBuffer, buffer_text);
            buffer_seek(_buildScriptBuffer, buffer_seek_start, buffer_get_size(_buildScriptBuffer));
        }
        catch(_error)
        {
            __DynamoError("Failed to load pre-build batch file \"", _buildScriptPath, "\"");
            return;
        }
        
        __DynamoTrace("Loaded \"", _buildScriptPath, "\"");
        
        if (string_count("dynamo_utility.exe", _buildScriptString) > 0) _buildScriptAlreadyExists = true;
    }
    
    buffer_save(_buildScriptBuffer, _buildScriptPath);
    buffer_delete(_buildScriptBuffer);
    
    if (_buildScriptAlreadyExists) __DynamoLoud("Dyanmo has already been added to pre-build batch file\n\nIf you're having issues, please try removing references to Dynamo from the pre-build batch file and then re-run this utility.");
    
    __DynamoLoud("Installation complete.\n\nI hope you enjoy using Dynamo!");
}

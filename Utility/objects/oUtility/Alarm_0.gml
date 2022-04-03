__Install = function(_directory)
{
    if (!__DynamoQuestion("Would you like to set up Dynamo for use with the project in this directory?\n\n", _directory)) return;
    
    __DynamoTrace("Installing Dynamo to ", _directory);
    
    var _projectJSON = __DynamoParseMainProjectJSON(_directory);
    if (_projectJSON == undefined)
    {
        __DynamoTrace("Failed to verify main project file");
        return;
    }
    
    __DynamoTrace("Main project file verified, installing Dynamo build script");
    
    var _commandString = "";
    _commandString += ":: Dynamo https://www.github.com/jujuadams/dynamo/\n";
    _commandString += "@echo off\n";
    _commandString += "echo Welcome to Dynamo by @jujuadams! This is version " + __DYNAMO_VERSION + ", " + __DYNAMO_DATE + "\n";
    _commandString += "\n";
    _commandString += "if not exist \"%YYprojectDir%\\dynamo.exe\" (\n";
    _commandString += "    echo\n";
    _commandString += "    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
    _commandString += "    echo dynamo.exe not found in \"%YYprojectDir%\"\n";
    _commandString += "    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
    _commandString += "    echo\n";
    _commandString += "    exit -1\n";
    _commandString += ")\n";
    _commandString += "\n";
    _commandString += "echo Running pre-build Dynamo utility in export mode...\n";
    _commandString += "\"%YYprojectDir%\\dynamo.exe\" -export\n";
    _commandString += "\n";
    _commandString += "echo Creating project directory link file...\n";
    _commandString += "@echo %YYprojectDir%\\> \"%YYoutputFolder%\\projectDirectory.dynamo\"\n";
    _commandString += "\n";
    _commandString += ":: Ensure complied assets are always copied into the temporary directory since GM checks datafiles *before* the pre-build step\n";
    _commandString += "echo Copying *.dynamo files to temporary directory...\n";
    _commandString += "for /R \"%YYprojectDir%\datafiles\" %%f in (*.dynamo) do copy \"%%f\" \"%YYoutputFolder%\"\n";
    _commandString += "\n";
    _commandString += "echo Dynamo pre-build complete\n";
    
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
        
        if (string_count("dynamo.exe", _buildScriptString) > 0)
        {
            _buildScriptAlreadyExists = true;
        }
        else
        {
            buffer_write(_buildScriptBuffer, buffer_text, "\n\n");
            buffer_write(_buildScriptBuffer, buffer_text, _commandString);
        }
    }
    
    buffer_save(_buildScriptBuffer, _buildScriptPath);
    buffer_delete(_buildScriptBuffer);
    
    if (_buildScriptAlreadyExists) __DynamoLoud("Dyanmo has already been added to pre-build batch file.\n\nIf you're having issues, please try removing references to Dynamo from the pre-build batch file and then re-run this utility.");
    
    __DynamoLoud("Installation complete.\n\nI hope you enjoy using Dynamo!");
}



__Export = function(_directory)
{
    __DynamoTrace("Exporting Notes from project in \"", _directory, "\"");
    
    var _projectJSON = __DynamoParseMainProjectJSON(_directory);
    if (_projectJSON == undefined)
    {
        __DynamoTrace("Failed to verify main project file");
        return;
    }
    
    var _notesArray = __DynamoMainProjectNotesArray(_projectJSON, _directory);
    
    var _datafilesDirectory = _directory + "datafiles\\";
    __DynamoTrace("Chose \"", _datafilesDirectory, "\" as export directory");
    
    var _i = 0;
    repeat(array_length(_notesArray))
    {
        _notesArray[_i].__Export(_datafilesDirectory);
        ++_i;
    }
    
    //Output manifest
    var _count = array_length(_notesArray);
    
    var _manifestBuffer = buffer_create(1024, buffer_grow, 1);
    buffer_write(_manifestBuffer, buffer_string, "Dynamo");
    buffer_write(_manifestBuffer, buffer_string, __DYNAMO_VERSION);
    buffer_write(_manifestBuffer, buffer_string, __DYNAMO_DATE);
    buffer_write(_manifestBuffer, buffer_u64, _count);
    
    var _i = 0;
    repeat(_count)
    {
        var _note = _notesArray[_i];
        buffer_write(_manifestBuffer, buffer_string, _note.__nameHash);
        ++_i;
    }
    
    var _outputPath = _datafilesDirectory + "manifest.dynamo";
    __DynamoBufferSave(_manifestBuffer, _outputPath, buffer_tell(_manifestBuffer));
    __DynamoTrace("Saved manifest to \"", _outputPath + "\"");
    
    //Done!
    __DynamoTrace("Export for project in \"", _directory, "\" complete");
}



if (global.__dynamoRunningFromIDE)
{
    __DynamoTrace("Running from IDE");
    
    if (false) //Change this to <true> to run in test mode
    {
        __DynamoLoud("Welcome to Dynamo by @jujuadams! This is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE, "\n\nRunning in test mode...");
        __Install("A:\\GitHub repos\\Mine\\Dynamo\\Library\\");
    }
    else
    {
        __DynamoLoud("Welcome to Dynamo by @jujuadams! This is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE, "\n\nPlease compile this project and place it into the root directory of a project before executing.");
    }
}
else
{
    __DynamoTrace("Running from from executable");
    
    //Clean up the weird broken parameter string that we might get passed
    var _i = 1;
    var _parameterString = "";
    repeat(parameter_count() - 1)
    {
        _parameterString += parameter_string(_i) + " ";
        ++_i;
    }
    
    var _pos = string_pos("-export", _parameterString);
    if (_pos <= 0)
    {
        //No -export, let's try to install!
        __DynamoLoud("Welcome to Dynamo by @jujuadams!\n\nThis is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE);
        __Install(filename_dir(_parameterString) + "\\");
    }
    else
    {
        __Export(filename_dir(string_copy(_parameterString, 1, _pos-1)) + "\\");
    }
}

game_end();

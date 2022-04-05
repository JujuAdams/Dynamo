__Setup = function(_directory)
{
    if (!__DynamoQuestion("Would you like to set up Dynamo for use with the project in this directory?\n\n", _directory)) return;
    
    __DynamoTrace("Setting up Dynamo in ", _directory);
    
    var _projectJSON = __DynamoParseMainProjectJSON(_directory);
    if (_projectJSON == undefined)
    {
        __DynamoTrace("Failed to verify main project file");
        return;
    }
    
    __DynamoTrace("Main project file verified");
    __DynamoTrace("Seting up Dynamo pre-build script");
    
    var _preBuildScriptAlreadyExists = false;
    var _preBuildScriptPath = _directory + "pre_build_step.bat";
    var _preBuildString = "";
    _preBuildString += ":: Dynamo " + __DYNAMO_VERSION + ", " + __DYNAMO_DATE + "    https://www.github.com/jujuadams/dynamo/\n";
    _preBuildString += "@echo off\n";
    _preBuildString += "echo Dynamo pre_build_step.bat version " + __DYNAMO_VERSION + ", " + __DYNAMO_DATE + "\n";
    _preBuildString += "\n";
    _preBuildString += "if not exist \"%YYprojectDir%\\dynamo.exe\" (\n";
    _preBuildString += "    echo\n";
    _preBuildString += "    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
    _preBuildString += "    echo dynamo.exe not found in \"%YYprojectDir%\"\n";
    _preBuildString += "    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
    _preBuildString += "    echo\n";
    _preBuildString += "    exit -1\n";
    _preBuildString += ")\n";
    _preBuildString += "\n";
    _preBuildString += "echo Running pre-build Dynamo utility in export mode...\n";
    _preBuildString += "\"%YYprojectDir%\\dynamo.exe\" -export\n";
    _preBuildString += "\n";
    _preBuildString += ":: Copy Dynamo datafiles into the temporary directory\n";
    _preBuildString += "echo Copying all files in \\datafilesDynamo\\ to temporary directory...\n";
    _preBuildString += "xcopy \"%YYprojectDir%\\datafilesDynamo\\*\" \"%YYoutputFolder%\" /c /f /s /r /y\n";
    _preBuildString += ":: for /R \"%YYprojectDir%\\datafiles\" %%f in (*.dynamo) do copy \"%%f\" \"%YYoutputFolder%\\\"\n";
    _preBuildString += "\n";
    _preBuildString += "echo Dynamo pre_build_step.bat complete\n";
    
    if (!file_exists(_preBuildScriptPath))
    {
        __DynamoTrace("Pre-build batch file not found \"", _preBuildScriptPath, "\", creating one");
        var _preBuildScriptBuffer = buffer_create(1024, buffer_grow, 1);
        
        buffer_write(_preBuildScriptBuffer, buffer_text, _preBuildString);
    }
    else
    {
        __DynamoTrace("Pre-build batch file found \"", _preBuildScriptPath, "\"");
        
        try
        {
            var _preBuildScriptBuffer = buffer_load(_preBuildScriptPath);
            var _buildScriptString = buffer_read(_preBuildScriptBuffer, buffer_text);
            buffer_seek(_preBuildScriptBuffer, buffer_seek_start, buffer_get_size(_preBuildScriptBuffer));
        }
        catch(_error)
        {
            __DynamoError("Failed to load pre-build batch file \"", _preBuildScriptPath, "\"");
            return;
        }
        
        __DynamoTrace("Loaded \"", _preBuildScriptPath, "\"");
        
        if (string_count("dynamo.exe", _buildScriptString) > 0)
        {
            _preBuildScriptAlreadyExists = true;
        }
        else
        {
            buffer_write(_preBuildScriptBuffer, buffer_text, "\n\n");
            buffer_write(_preBuildScriptBuffer, buffer_text, _preBuildString);
        }
    }
    
    buffer_save(_preBuildScriptBuffer, _preBuildScriptPath);
    buffer_delete(_preBuildScriptBuffer);
    
    
    
    __DynamoTrace("Setting up Dynamo pre-run script");
    
    var _preRunAlreadyExists = false;
    var _preRunPath = _directory + "pre_run_step.bat";
    var _preRunString = "";
    _preRunString += ":: Dynamo " + __DYNAMO_VERSION + ", " + __DYNAMO_DATE + "    https://www.github.com/jujuadams/dynamo/\n";
    _preRunString += "@echo off\n";
    _preRunString += "echo Dynamo pre_run_step.bat version " + __DYNAMO_VERSION + ", " + __DYNAMO_DATE + "\n";
    _preRunString += "\n";
    _preRunString += "echo Dynamo creating project directory link file...\n";
    _preRunString += "@echo %YYprojectDir%\\> \"%YYoutputFolder%\\projectDirectory.dynamo\"\n";
    _preRunString += "\n";
    _preRunString += "echo Dynamo pre_run_step.bat complete\n";
    
    if (!file_exists(_preRunPath))
    {
        __DynamoTrace("Pre-run batch file not found \"", _preRunPath, "\", creating one");
        var _preRunBuffer = buffer_create(1024, buffer_grow, 1);
        
        buffer_write(_preRunBuffer, buffer_text, _preRunString);
    }
    else
    {
        __DynamoTrace("Pre-run batch file found \"", _preRunPath, "\"");
        
        try
        {
            var _preRunBuffer = buffer_load(_preRunPath);
            var _runScriptString = buffer_read(_preRunBuffer, buffer_text);
            buffer_seek(_preRunBuffer, buffer_seek_start, buffer_get_size(_preRunBuffer));
        }
        catch(_error)
        {
            __DynamoError("Failed to load pre-run batch file \"", _preRunPath, "\"");
            return;
        }
        
        __DynamoTrace("Loaded \"", _preRunPath, "\"");
        
        if (string_count("dynamo.exe", _runScriptString) > 0)
        {
            _preRunAlreadyExists = true;
        }
        else
        {
            buffer_write(_preRunBuffer, buffer_text, "\n\n");
            buffer_write(_preRunBuffer, buffer_text, _preRunString);
        }
    }
    
    buffer_save(_preRunBuffer, _preRunPath);
    buffer_delete(_preRunBuffer);
    
    
    
    var _fileDirectory = _directory + "datafilesDynamo";
    __DynamoTrace("Creating \"datafilesDynamo\" file directory at \"", _fileDirectory, "\"");
    directory_create(_fileDirectory);
    
    
    
    if (_preBuildScriptAlreadyExists) __DynamoLoud("Dyanmo has already been added to pre-build batch file.\n\nIf you're having issues, please try removing references to Dynamo from the pre-build batch file and then re-run this utility.");
    if (_preRunAlreadyExists) __DynamoLoud("Dyanmo has already been added to pre-run batch file.\n\nIf you're having issues, please try removing references to Dynamo from the pre-run batch file and then re-run this utility.");
    
    __DynamoLoud("Setup complete.\n\nI hope you enjoy using Dynamo!");
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
    
    var _datafilesDirectory = _directory + "datafilesDynamo\\";
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
    
    if (true) //Change this to <true> to run in test mode
    {
        __DynamoLoud("Welcome to Dynamo by @jujuadams! This is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE, "\n\nRunning in test mode...");
        __Setup("A:\\GitHub repos\\Mine\\Dynamo\\Library\\");
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
        //No -export, let's try to setup!
        __DynamoLoud("Welcome to Dynamo by @jujuadams!\n\nThis is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE);
        __Setup(filename_dir(_parameterString) + "\\");
    }
    else
    {
        __Export(filename_dir(string_copy(_parameterString, 1, _pos-1)) + "\\");
    }
}

game_end();

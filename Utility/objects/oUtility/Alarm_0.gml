__Setup = function(_directory)
{
    if (!__showQuestion("Would you like to set up Dynamo for use with the project in this directory?\n\n", _directory)) return;
    
    __DynamoTrace("Setting up Dynamo in ", _directory);
    
    __DynamoTrace("Checking for erroneous data in game_save_id (", game_save_id, ")...");
    if (directory_exists(game_save_id))
    {
        __DynamoTrace(game_save_id, " exists...");
        
        if (file_exists(game_save_id + "pre_build_step.bat"))
        {
            __DynamoTrace(game_save_id + "pre_build_step.bat", " exists, deleting");
            file_delete(game_save_id + "pre_build_step.bat");
        }
        
        if (file_exists(game_save_id + "pre_run_step.bat"))
        {
            __DynamoTrace(game_save_id + "pre_run_step.bat", " exists, deleting");
            file_delete(game_save_id + "pre_run_step.bat");
        }
        
        if (directory_exists(game_save_id + "datafilesDynamo\\"))
        {
            __DynamoTrace(game_save_id + "datafilesDynamo\\", " exists, deleting");
            directory_destroy(game_save_id + "datafilesDynamo\\");
        }
    }
    __DynamoTrace("...check ended");
    
    var _projectJSON = __DynamoParseMainProjectJSON(_directory);
    if (_projectJSON == undefined)
    {
        __DynamoTrace("Failed to verify main project file");
        return;
    }
    
    __DynamoTrace("Main project file verified");
    __DynamoTrace("Setting up Dynamo in pre_build_step.bat");
    
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
    _preBuildString += "\"%YYprojectDir%\\dynamo.exe\" -export \"%YYoutputFolder%\\\"\n";
    _preBuildString += "\n";
    _preBuildString += ":: Copy Dynamo datafiles into the temporary directory\n";
    _preBuildString += "echo Copying all files in \\datafilesDynamo\\ to temporary directory...\n";
    _preBuildString += "xcopy \"%YYprojectDir%\\datafilesDynamo\\*\" \"%YYoutputFolder%\" /c /f /s /r /y\n";
    _preBuildString += "\n";
    _preBuildString += "echo Dynamo pre_build_step.bat complete\n";
    
    if (!file_exists(_preBuildScriptPath))
    {
        __DynamoTrace("\"", _preBuildScriptPath, "\" not found, creating pre_build_step.bat");
        var _preBuildScriptBuffer = buffer_create(1024, buffer_grow, 1);
        
        buffer_write(_preBuildScriptBuffer, buffer_text, _preBuildString);
    }
    else
    {
        __DynamoTrace("Found \"", _preBuildScriptPath, "\"");
        
        try
        {
            var _preBuildScriptBuffer = buffer_load(_preBuildScriptPath);
            var _buildScriptString = buffer_read(_preBuildScriptBuffer, buffer_text);
            buffer_seek(_preBuildScriptBuffer, buffer_seek_start, buffer_get_size(_preBuildScriptBuffer));
        }
        catch(_error)
        {
            __DynamoError("Failed to load \"", _preBuildScriptPath, "\"");
            return;
        }
        
        __DynamoTrace("Loaded \"", _preBuildScriptPath, "\"");
        __DynamoTrace(_buildScriptString);
        
        if (string_count(":: Dynamo", _buildScriptString) > 0)
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
    
    
    
    __DynamoTrace("Setting up Dynamo in pre_run_step.bat");
    
    var _preRunAlreadyExists = false;
    var _preRunPath = _directory + "pre_run_step.bat";
    var _preRunString = "";
    _preRunString += ":: Dynamo " + __DYNAMO_VERSION + ", " + __DYNAMO_DATE + "    https://www.github.com/jujuadams/dynamo/\n";
    _preRunString += "@echo off\n";
    _preRunString += "echo Dynamo pre_run_step.bat version " + __DYNAMO_VERSION + ", " + __DYNAMO_DATE + "\n";
    _preRunString += "\n";
    _preRunString += "echo Dynamo creating project directory link file...\n";
    _preRunString += "@echo %YYprojectDir%\\> \"%YYoutputFolder%\\" + __DYNAMO_PROJECT_DIRECTORY_PATH_NAME + "\"\n";
    _preRunString += "\n";
    _preRunString += ":: Make sure we don't have a symlink left over from the last run\n";
    _preRunString += "del \"%~dp0\\" + __DYNAMO_SYMLINK_TO_WORKING_DIRECTORY_NAME + "\" /f /q\n";
    _preRunString += "\n";
    _preRunString += "echo Creating symlink to working directory...\n";
    _preRunString += "mklink /d \"%~dp0\\" + __DYNAMO_SYMLINK_TO_WORKING_DIRECTORY_NAME + "\" \"%YYoutputFolder%\\\"\n";
    _preRunString += "\n";
    _preRunString += "echo Dynamo pre_run_step.bat complete\n";
    
    if (!file_exists(_preRunPath))
    {
        __DynamoTrace("\"", _preRunPath, "\" not found, creating pre_run_step.bat");
        var _preRunBuffer = buffer_create(1024, buffer_grow, 1);
        
        buffer_write(_preRunBuffer, buffer_text, _preRunString);
    }
    else
    {
        __DynamoTrace("Found \"", _preRunPath, "\"");
        
        try
        {
            var _preRunBuffer = buffer_load(_preRunPath);
            var _preRunScriptString = buffer_read(_preRunBuffer, buffer_text);
            buffer_seek(_preRunBuffer, buffer_seek_start, buffer_get_size(_preRunBuffer));
        }
        catch(_error)
        {
            __DynamoError("Failed to load \"", _preRunPath, "\"");
            return;
        }
        
        __DynamoTrace("Loaded \"", _preRunPath, "\"");
        __DynamoTrace(_preRunScriptString);
        
        if (string_count(":: Dynamo", _preRunScriptString) > 0)
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
    
    
    
    __DynamoTrace("Setting up Dynamo in post_run_step.bat");
    
    var _postRunAlreadyExists = false;
    var _postRunPath = _directory + "post_run_step.bat";
    var _postRunString = "";
    _postRunString += ":: Dynamo " + __DYNAMO_VERSION + ", " + __DYNAMO_DATE + "    https://www.github.com/jujuadams/dynamo/\n";
    _postRunString += "@echo off\n";
    _postRunString += "echo Dynamo post_run_step.bat version " + __DYNAMO_VERSION + ", " + __DYNAMO_DATE + "\n";
    _postRunString += "\n";
    _postRunString += ":: Clear up the symlink from this run\n";
    _postRunString += "del \"%~dp0\\" + __DYNAMO_SYMLINK_TO_WORKING_DIRECTORY_NAME + "\" /f /q\n";
    _postRunString += "\n";
    _postRunString += "echo Dynamo post_run_step.bat complete\n";
    
    if (!file_exists(_postRunPath))
    {
        __DynamoTrace("\"", _postRunPath, "\" not found, creating post_run_step.bat");
        var _postRunBuffer = buffer_create(1024, buffer_grow, 1);
        
        buffer_write(_postRunBuffer, buffer_text, _postRunString);
    }
    else
    {
        __DynamoTrace("Found \"", _postRunPath, "\"");
        
        try
        {
            var _postRunBuffer = buffer_load(_postRunPath);
            var _postRunScriptString = buffer_read(_postRunBuffer, buffer_text);
            buffer_seek(_postRunBuffer, buffer_seek_start, buffer_get_size(_postRunBuffer));
        }
        catch(_error)
        {
            __DynamoError("Failed to load \"", _postRunPath, "\"");
            return;
        }
        
        __DynamoTrace("Loaded \"", _postRunPath, "\"");
        __DynamoTrace(_postRunScriptString);
        
        if (string_count(":: Dynamo", _postRunScriptString) > 0)
        {
            _postRunAlreadyExists = true;
        }
        else
        {
            buffer_write(_postRunBuffer, buffer_text, "\n\n");
            buffer_write(_postRunBuffer, buffer_text, _postRunString);
        }
    }
    
    buffer_save(_postRunBuffer, _postRunPath);
    buffer_delete(_postRunBuffer);
    
    
    
    var _fileDirectory = _directory + "datafilesDynamo";
    __DynamoTrace("Creating \"datafilesDynamo\" file directory at \"", _fileDirectory, "\"");
    directory_create(_fileDirectory);
    
    
    
    if (_preBuildScriptAlreadyExists) __showMessage("Dyanmo has already been added to pre_build_step.bat\n\nIf you're having issues, please try removing references to Dynamo from pre_build_step.bat and then re-run this utility.");
    if (_preRunAlreadyExists) __showMessage("Dyanmo has already been added to pre_run_step.bat\n\nIf you're having issues, please try removing references to Dynamo from pre_run_step.bat and then re-run this utility.");
    if (_postRunAlreadyExists) __showMessage("Dyanmo has already been added to post_run_step.bat\n\nIf you're having issues, please try removing references to Dynamo from post_run_step.bat and then re-run this utility.");
    
    __showMessage("Setup complete.\n\nI hope you enjoy using Dynamo!");
}



if (global.__dynamoRunningFromIDE)
{
    __DynamoTrace("Running from IDE");
    
    if (true) //Change this to <true> to run in test mode
    {
        __showMessage("Welcome to Dynamo by @jujuadams! This is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE, "\n\nRunning in test mode...");
        __Setup("A:\\GitHub repos\\Mine\\Dynamo\\Library\\");
    }
    else
    {
        __showMessage("Welcome to Dynamo by @jujuadams! This is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE, "\n\nPlease compile this project and place it into the root directory of a project before executing.");
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
    if (_pos <= 0)
    {
        //No -export, let's try to setup!
        __showMessage("Welcome to Dynamo by @jujuadams!\n\nThis is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE);
        __Setup(filename_dir(_parameterString) + "\\");
    }
    else
    {
        var _projectDirectory = filename_dir(string_copy(_parameterString, 1, _pos-1)) + "\\";
        var _exportDirectory  = string_delete(_parameterString, 1, _pos + string_length("-export"));
        
        __DynamoTrace("Exporting Notes from project in \"", _projectDirectory, "\" to \"", _exportDirectory, "\"");
        __DynamoCheckForNoteChanges(undefined, _projectDirectory, _exportDirectory);
        
        //Done!
        __DynamoTrace("Export complete");
    }
}

game_end();

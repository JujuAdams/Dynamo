var _directory = directory;

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
_preBuildString += ":: Dynamo Block Start\n";
_preBuildString += ":: " + __DYNAMO_VERSION + ", " + __DYNAMO_DATE + "\n";
_preBuildString += ":: https://www.github.com/jujuadams/dynamo/\n";
_preBuildString += "@echo off\n";
_preBuildString += "echo Dynamo pre_build_step.bat version " + __DYNAMO_VERSION + ", " + __DYNAMO_DATE + "\n";
_preBuildString += "\n";
_preBuildString += "if not exist \"%YYprojectDir%\\dynamo_server.exe\" (\n";
_preBuildString += "    echo\n";
_preBuildString += "    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
_preBuildString += "    echo dynamo_server.exe not found in \"%YYprojectDir%\"\n";
_preBuildString += "    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
_preBuildString += "    echo\n";
_preBuildString += "    exit -1\n";
_preBuildString += ")\n";
_preBuildString += "\n";
_preBuildString += "echo Running pre-build Dynamo utility in export mode...\n";
_preBuildString += "\"%YYprojectDir%\\dynamo_server.exe\" -export \"%YYoutputFolder%\\\"\n";
_preBuildString += "\n";
_preBuildString += ":: Copy Dynamo datafiles into the temporary directory\n";
_preBuildString += "echo Copying all files in \\datafilesDynamo\\ to temporary directory...\n";
_preBuildString += "xcopy \"%YYprojectDir%\\datafilesDynamo\\*\" \"%YYoutputFolder%\" /c /f /s /r /y\n";
_preBuildString += "\n";
_preBuildString += "echo Dynamo pre_build_step.bat complete\n";
_preBuildString += ":: Dynamo Block End\n";
    
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
    
    if (string_count(":: Dynamo Block Start", _buildScriptString) > 0)
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
_preRunString += ":: Dynamo Block Start\n";
_preRunString += ":: " + __DYNAMO_VERSION + ", " + __DYNAMO_DATE + "\n";
_preRunString += ":: https://www.github.com/jujuadams/dynamo/\n";
_preRunString += "@echo off\n";
_preRunString += "setlocal enabledelayedexpansion\n";
_preRunString += "echo Dynamo pre_run_step.bat version " + __DYNAMO_VERSION + ", " + __DYNAMO_DATE + "\n";
_preRunString += "\n";
_preRunString += "echo Dynamo creating project directory link file...\n";
_preRunString += "@echo %YYprojectDir%\\> \"%YYoutputFolder%\\" + __DYNAMO_PROJECT_DIRECTORY_PATH_NAME + "\"\n";
_preRunString += "\n";
_preRunString += ":: Make sure we don't have a symlink left over from the last run\n";
_preRunString += "del \"%~dp0\\" + __DYNAMO_SYMLINK_TO_WORKING_DIRECTORY_NAME + "\" /f /q\n";
_preRunString += "rmdir \"%~dp0\\" + __DYNAMO_SYMLINK_TO_WORKING_DIRECTORY_NAME + "\" /s /q\n";
_preRunString += "\n";
_preRunString += "echo Creating symlink to working directory...\n";
_preRunString += "mklink /d \"%~dp0\\" + __DYNAMO_SYMLINK_TO_WORKING_DIRECTORY_NAME + "\" \"%YYoutputFolder%\\\"\n";
_preRunString += "\n";
_preRunString += ":: Now generate a 16 byte random hex string to use as the server ident\n";
_preRunString += ":: This ensures that the client and server can find each other on a busy network\n";
_preRunString += "echo Generating server ident...\n";
_preRunString += "set \"DynamoHexString=0123456789abcdef\"\n";
_preRunString += "set \"DynamoRandom=\"\n";
_preRunString += "for /L %%i in (1,1,20) do call :DynamoIdentConcat\n";
_preRunString += "goto :DynamoIdentDone\n";
_preRunString += "\n";
_preRunString += ":DynamoIdentConcat\n";
_preRunString += "set /a x=%random% %% 16 \n";
_preRunString += "set DynamoRandom=%DynamoRandom%!DynamoHexString:~%x%,1!\n";
_preRunString += "goto :eof\n";
_preRunString += "\n";
_preRunString += ":DynamoIdentDone\n";
_preRunString += "echo Generated server ident as %DynamoRandom%\n";
_preRunString += "@echo %DynamoRandom%> \"%YYtempFolder%\\dynamoServerIdent\"\n";
_preRunString += "@echo %DynamoRandom%> \"%YYoutputFolder%\\dynamoServerIdent\"\n";
_preRunString += "\n";
_preRunString += "powershell Start-Process -FilePath \\\"%YYprojectDir%\\dynamo_server.exe\\\" -ArgumentList \\\"-serverOnly %YYoutputFolder%\\\"\n";
_preRunString += "\n";
_preRunString += "echo Dynamo pre_run_step.bat complete\n";
_preRunString += ":: Dynamo Block End\n";

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
    
    if (string_count(":: Dynamo Block Start", _buildScriptString) > 0)
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



if (_preBuildScriptAlreadyExists) __DynamoLoud("Dyanmo has already been added to pre_build_step.bat\n\nIf you're having issues, please try removing references to Dynamo from pre_build_step.bat and then re-run this utility.");
if (_preRunAlreadyExists) __DynamoLoud("Dyanmo has already been added to pre_run_step.bat\n\nIf you're having issues, please try removing references to Dynamo from pre_run_step.bat and then re-run this utility.");

__DynamoLoud("Setup complete.\n\nI hope you enjoy using Dynamo!");

game_end();
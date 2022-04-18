var _directory = directory;

if (!__showQuestion("Would you like to set up Dynamo for use with the project in this directory?\n\n", _directory))
{
    game_end();
    return;
}
    
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

var _dynamoBlockStart = ":::: Dynamo Block Start ::::";
var _dynamoBlockEnd   = ":::: Dynamo Block End ::::";

var _preBuildError = false;
var _preBuildBatPath = _directory + "pre_build_step.bat";
var _preBuildString = "";
_preBuildString += _dynamoBlockStart + "\n";
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
_preBuildString += _dynamoBlockEnd + "\n";

if (string_char_at(_preBuildString, string_length(_preBuildString)) == "\n") _preBuildString = string_delete(_preBuildString, string_length(_preBuildString), 1);

if (!file_exists(_preBuildBatPath))
{
    __DynamoTrace("\"", _preBuildBatPath, "\" not found, creating pre_build_step.bat");
    var _preBuildBatBuffer = buffer_create(1024, buffer_grow, 1);
    
    buffer_write(_preBuildBatBuffer, buffer_text, _preBuildString);
}
else
{
    __DynamoTrace("Found \"", _preBuildBatPath, "\"");
        
    try
    {
        var _preBuildBatBuffer = buffer_load(_preBuildBatPath);
        var _preBuildBatString = buffer_read(_preBuildBatBuffer, buffer_text);
        buffer_seek(_preBuildBatBuffer, buffer_seek_start, buffer_get_size(_preBuildBatBuffer));
    }
    catch(_error)
    {
        __DynamoError("Failed to load \"", _preBuildBatPath, "\"");
        return;
    }
        
    __DynamoTrace("Loaded \"", _preBuildBatPath, "\"");
    
    var _countLegacy     = string_count("echo Dynamo", _preBuildBatString);
    var _countBlockStart = string_count(_dynamoBlockStart, _preBuildBatString);
    var _countBlockEnd   = string_count(_dynamoBlockEnd,   _preBuildBatString);
    var _posBlockStart   = string_pos(  _dynamoBlockStart, _preBuildBatString);
    var _posBlockEnd     = string_pos(  _dynamoBlockEnd,   _preBuildBatString);
    
    if ((_countBlockStart == 0) && (_countBlockEnd == 0))
    {
        //Append the build script to the batch file
        buffer_write(_preBuildBatBuffer, buffer_text, "\n\n");
        buffer_write(_preBuildBatBuffer, buffer_text, _preBuildString);
    }
    else if (_countLegacy > 0)
    {
        _preBuildError = true;
    }
    else if ((_countBlockStart == 1) && (_countBlockEnd == 1))
    {
        _preBuildBatString = string_copy(_preBuildBatString, 1, _posBlockStart - 1)
                           + _preBuildString
                           + string_copy(_preBuildBatString, _posBlockEnd + string_length(_dynamoBlockEnd), 1 + string_length(_preBuildBatString) - (_posBlockEnd + string_length(_dynamoBlockEnd)));
        
        buffer_resize(_preBuildBatBuffer, string_byte_length(_preBuildBatString));
        buffer_seek(_preBuildBatBuffer, buffer_seek_start, 0);
        buffer_write(_preBuildBatBuffer, buffer_text, _preBuildBatString);
    }
    else
    {
        _preBuildError = true;
    }
}

buffer_save(_preBuildBatBuffer, _preBuildBatPath);
buffer_delete(_preBuildBatBuffer);



__DynamoTrace("Setting up Dynamo in pre_run_step.bat");

var _preRunError = false;
var _preRunPath = _directory + "pre_run_step.bat";
var _preRunString = "";
_preRunString += _dynamoBlockStart + "\n";
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
_preRunString += ":: Use Powershell to spin up the server without the batch file waiting for it to complete execution\n";
_preRunString += "powershell Start-Process -FilePath \\\"%YYprojectDir%\\dynamo_server.exe\\\" -ArgumentList \\\"-server %DynamoRandom%\\\"\n";
_preRunString += "\n";
_preRunString += "echo Dynamo pre_run_step.bat complete\n";
_preRunString += _dynamoBlockEnd + "\n";

if (string_char_at(_preRunString, string_length(_preRunString)) == "\n") _preRunString = string_delete(_preRunString, string_length(_preRunString), 1);

if (!file_exists(_preRunPath))
{
    __DynamoTrace("\"", _preRunPath, "\" not found, creating pre_run_step.bat");
    var _preRunBatBuffer = buffer_create(1024, buffer_grow, 1);
    
    buffer_write(_preRunBatBuffer, buffer_text, _preRunString);
}
else
{
    __DynamoTrace("Found \"", _preRunPath, "\"");
    
    try
    {
        var _preRunBatBuffer = buffer_load(_preRunPath);
        var _preRunBatString = buffer_read(_preRunBatBuffer, buffer_text);
        buffer_seek(_preRunBatBuffer, buffer_seek_start, buffer_get_size(_preRunBatBuffer));
    }
    catch(_error)
    {
        __DynamoError("Failed to load \"", _preRunPath, "\"");
        return;
    }
    
    __DynamoTrace("Loaded \"", _preRunPath, "\"");
    
    var _countLegacy     = string_count("echo Dynamo", _preRunBatString);
    var _countBlockStart = string_count(_dynamoBlockStart, _preRunBatString);
    var _countBlockEnd   = string_count(_dynamoBlockEnd,   _preRunBatString);
    var _posBlockStart   = string_pos(  _dynamoBlockStart, _preRunBatString);
    var _posBlockEnd     = string_pos(  _dynamoBlockEnd,   _preRunBatString);
    
    if ((_countBlockStart == 0) && (_countBlockEnd == 0))
    {
        //Append the build script to the batch file
        buffer_write(_preRunBatBuffer, buffer_text, "\n\n");
        buffer_write(_preRunBatBuffer, buffer_text, _preRunString);
    }
    else if (_countLegacy > 0)
    {
        _preBuildError = true;
    }
    else if ((_countBlockStart == 1) && (_countBlockEnd == 1))
    {
        _preRunBatString = string_copy(_preRunBatString, 1, _posBlockStart - 1)
                         + _preRunString
                         + string_copy(_preRunBatString, _posBlockEnd + string_length(_dynamoBlockEnd), 1 + string_length(_preRunBatString) - (_posBlockEnd + string_length(_dynamoBlockEnd)));
        
        buffer_resize(_preRunBatBuffer, string_byte_length(_preRunBatString));
        buffer_seek(_preRunBatBuffer, buffer_seek_start, 0);
        buffer_write(_preRunBatBuffer, buffer_text, _preRunBatString);
    }
    else
    {
        _preRunError = true;
    }
}

buffer_save(_preRunBatBuffer, _preRunPath);
buffer_delete(_preRunBatBuffer);



var _fileDirectory = _directory + "datafilesDynamo";
__DynamoTrace("Creating \"datafilesDynamo\" file directory at \"", _fileDirectory, "\"");
directory_create(_fileDirectory);



if (_preBuildError) __DynamoLoud("Dynamo pre-build script was found in pre_build_step.bat but it appears to be corrupted\n\nPlease remove any references to Dynamo from pre_build_step.bat and then re-run this utility.");
if (_preRunError) __DynamoLoud("Dynamo pre-run script was found in pre_run_step.bat but it appears to be corrupted\n\nPlease remove any references to Dynamo from pre_run_step.bat and then re-run this utility.");

__DynamoLoud("Setup complete.\n\nI hope you enjoy using Dynamo!");

game_end();

:: Dynamo 0.1.0, 2022-04-07    https://www.github.com/jujuadams/dynamo/
@echo off
echo Dynamo pre_run_step.bat version 0.1.0, 2022-04-07

echo Dynamo creating project directory path file...
@echo %YYprojectDir%\> "%YYoutputFolder%\pathToProjectDirectory"

:: Make sure we don't have a symlink left over from the last run
del "%~dp0\symlinkToWorkingDirectory" /f /q

echo Creating symlink to working directory...
mklink /d "%~dp0\symlinkToWorkingDirectory" "%YYoutputFolder%\"

echo Dynamo pre_run_step.bat complete

:: Dynamo 0.4.0, 2022-04-08    https://www.github.com/jujuadams/dynamo/
@echo off
echo Dynamo pre_run_step.bat version 0.4.0, 2022-04-08

echo Dynamo creating project directory link file...
@echo %YYprojectDir%\> "%YYoutputFolder%\projectDirectoryPath.dynamo"

:: Make sure we don't have a symlink left over from the last run
del "%~dp0\symlinkToWorkingDirectory.dynamo" /f /q
rmdir "%~dp0\symlinkToWorkingDirectory.dynamo" /s /q

echo Creating symlink to working directory...
mklink /d "%~dp0\symlinkToWorkingDirectory.dynamo" "%YYoutputFolder%\"

echo Dynamo pre_run_step.bat complete

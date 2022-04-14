:: Dynamo 1.1.0, 2022-04-14    https://www.github.com/jujuadams/dynamo/
@echo off
echo Dynamo pre_run_step.bat version 1.1.0, 2022-04-14

echo Dynamo creating project directory link file...
@echo %YYprojectDir%\> "%YYoutputFolder%\projectDirectoryPath"

:: Make sure we don't have a symlink left over from the last run
del "%~dp0\symlinkToWorkingDirectory" /f /q
rmdir "%~dp0\symlinkToWorkingDirectory" /s /q

echo Creating symlink to working directory...
mklink /d "%~dp0\symlinkToWorkingDirectory" "%YYoutputFolder%\"

echo Dynamo pre_run_step.bat complete

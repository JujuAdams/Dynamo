:: Dynamo Block Start
:: 2.0.0 alpha, 2022-04-18
:: https://www.github.com/jujuadams/dynamo/
@echo off
setlocal enabledelayedexpansion
echo Dynamo pre_run_step.bat version 2.0.0 alpha, 2022-04-18

echo Dynamo creating project directory link file...
@echo %YYprojectDir%\> "%YYoutputFolder%\projectDirectoryPath"

:: Make sure we don't have a symlink left over from the last run
del "%~dp0\symlinkToWorkingDirectory" /f /q
rmdir "%~dp0\symlinkToWorkingDirectory" /s /q

echo Creating symlink to working directory...
mklink /d "%~dp0\symlinkToWorkingDirectory" "%YYoutputFolder%\"

:: Now generate a 16 byte random hex string to use as the server ident
:: This ensures that the client and server can find each other on a busy network
echo Generating server ident...
set "DynamoHexString=0123456789abcdef"
set "DynamoRandom="
for /L %%i in (1,1,20) do call :DynamoIdentConcat
goto :DynamoIdentDone

:DynamoIdentConcat
set /a x=%random% %% 16 
set DynamoRandom=%DynamoRandom%!DynamoHexString:~%x%,1!
goto :eof

:DynamoIdentDone
echo Generated server ident as %DynamoRandom%
@echo %DynamoRandom%> "%YYtempFolder%\dynamoServerIdent"
@echo %DynamoRandom%> "%YYoutputFolder%\dynamoServerIdent"

powershell Start-Process -FilePath \"%YYprojectDir%\dynamo_server.exe\" -ArgumentList \"-serverOnly %YYoutputFolder%\"

echo Dynamo pre_run_step.bat complete
:: Dynamo Block End

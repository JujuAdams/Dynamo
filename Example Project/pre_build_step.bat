:: !!

:: Dynamo Block Start
:: 2.0.0 alpha 2, 2022-04-18
:: https://www.github.com/jujuadams/dynamo/
@echo off
echo Dynamo pre_build_step.bat version 2.0.0 alpha 2, 2022-04-18

if not exist "%YYprojectDir%\dynamo_server.exe" (
    echo
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    echo dynamo_server.exe not found in "%YYprojectDir%"
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    echo
    exit -1
)

echo Running pre-build Dynamo utility in export mode...
"%YYprojectDir%\dynamo_server.exe" -export "%YYoutputFolder%\"

:: Copy Dynamo datafiles into the temporary directory
echo Copying all files in \datafilesDynamo\ to temporary directory...
xcopy "%YYprojectDir%\datafilesDynamo\*" "%YYoutputFolder%" /c /f /s /r /y

echo Dynamo pre_build_step.bat complete
:: Dynamo Block End

:: !!
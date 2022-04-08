:: Dynamo 0.4.0, 2022-04-08    https://www.github.com/jujuadams/dynamo/
@echo off
echo Dynamo pre_build_step.bat version 0.4.0, 2022-04-08

if not exist "%YYprojectDir%\dynamo.exe" (
    echo
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    echo dynamo.exe not found in "%YYprojectDir%"
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    echo
    exit -1
)

echo Running pre-build Dynamo utility in export mode...
"%YYprojectDir%\dynamo.exe" -export "%YYoutputFolder%\"

:: Copy Dynamo datafiles into the temporary directory
echo Copying all files in \datafilesDynamo\ to temporary directory...
xcopy "%YYprojectDir%\datafilesDynamo\*" "%YYoutputFolder%" /c /f /s /r /y

echo Dynamo pre_build_step.bat complete

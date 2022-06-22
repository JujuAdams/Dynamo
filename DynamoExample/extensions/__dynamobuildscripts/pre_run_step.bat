@echo off

if not exist "%YYprojectDir%/pre_project_step.bat" (
    @echo :: Autogenerated by Dynamo>> "%YYprojectDir%/pre_project_step.bat"
    @echo call "%YYprojectDir%/extensions/__dynamobuildscripts/DynamoParser.exe" "%YYprojectDir%/">> "%YYprojectDir%/pre_project_step.bat"

    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    echo !!                                                            !!
    echo !!  Dynamo has now been inserted into GameMaker's build flow  !!
    echo !!  Please run your game again                                !!
    echo !!                                                            !!
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    exit -1
)

findstr "Autogenerated by Dynamo" "%YYprojectDir%\pre_project_step.bat"
if %errorlevel% == 1 (
    @echo.>> "%YYprojectDir%/pre_project_step.bat"
    @echo.>> "%YYprojectDir%/pre_project_step.bat"
    @echo :: Autogenerated by Dynamo>> "%YYprojectDir%/pre_project_step.bat"
    @echo call "%YYprojectDir%/extensions/__dynamobuildscripts/DynamoParser.exe" "%YYprojectDir%/">> "%YYprojectDir%/pre_project_step.bat"

    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    echo !!                                                            !!
    echo !!  Dynamo has now been inserted into GameMaker's build flow  !!
    echo !!  Please run your game again                                !!
    echo !!                                                            !!
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    exit -2
)

:: Save a text file that contains the project path
:: This is accessed on boot by Dynamo (see __DynamoSystem())
@echo %YYprojectDir%> "%YYoutputFolder%/projectDirectory.txt"
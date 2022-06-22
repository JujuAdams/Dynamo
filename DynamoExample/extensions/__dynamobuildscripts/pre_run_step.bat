@echo off

:: Save a text file that contains the project path
:: This is accessed on boot by Dynamo (see __DynamoSystem())
@echo %YYprojectDir%> "%YYoutputFolder%/projectDirectory.txt"
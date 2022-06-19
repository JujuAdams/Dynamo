@echo %YYprojectDir%> "%YYoutputFolder%/projectDirectory.txt"
if exist "%YYprojectDir%/DynamoRestoreBackups.bat" call "%YYprojectDir%/DynamoRestoreBackups.bat"
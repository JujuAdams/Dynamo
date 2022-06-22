:: If there's a restoration batch file then we should call it
:: This returns code on disk to whatever the dev had before Dynamo fiddled with it
if exist "%YYprojectDir%/DynamoRestoreBackups.bat" call "%YYprojectDir%/DynamoRestoreBackups.bat"
/// Saves a buffer (synchronously) to the project's datafilesDynamo directory and the working directory
/// This function will do nothing if DYNAMO_DEV_MODE is set to <false> or the game is *not* being run from the IDE
/// 
/// @param buffer  Buffer to save to the file
/// @param path    Path for the file to save, relative to the datafilesDynamo directory in your project's root directory

function DynamoDevSaveBuffer(_buffer, _path)
{
    if (!__DYNAMO_DEV_MODE) return;
    
    var _savePath = DynamoDevProjectDirectory() + "datafilesDynamo\\" + _path;
    __DynamoTrace("Saving buffer ", _buffer, " to \"", _savePath, "\"");
    buffer_save(_buffer, _savePath);
    
    if (variable_struct_exists(global.__dynamoFileDictionary, _savePath))
    {
        var _hash = md5_file(_savePath);
        global.__dynamoFileDictionary[$ _savePath].__dataHash = _hash;
        __DynamoTrace("Updated datafile record for \"", _savePath, "\" (hash = ", _hash, ")");
    }
    else
    {
        global.__dynamoFileDictionary[$ _savePath] = new __DynamoClassFile(_savePath, false);
    }
    
    var _savePath = global.__dynamoWorkingDirectory + _path;
    __DynamoTrace("Saving buffer ", _buffer, " to \"", _savePath, "\"");
    buffer_save(_buffer, _savePath);
}

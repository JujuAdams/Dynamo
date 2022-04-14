/// Saves a buffer (synchronously) to a Note asset in the project
/// If the note does not exist then this function will fail
/// Care should be taken to ensure that the data being written can be rendered as text or GameMaker may corrupt the file
/// This function will do nothing if DYNAMO_DEV_MODE is set to <false> or the game is *not* being run from the IDE
/// 
/// @param buffer     Buffer to save to the Note asset
/// @param noteAsset  Note asset to save to. If the Note doesn't exist then this function will fail

function DynamoDevSaveNoteBuffer(_buffer, _note)
{
    if (!__DYNAMO_DEV_MODE) return;
    
    var _nameHash = md5_string_utf8(_note);
    if (!variable_struct_exists(global.__dynamoNoteDictionary, _nameHash))
    {
        __DynamoTrace("Cannot save buffer to Note asset \"", _note, "\", name hash not found in dictionary (", _nameHash, ")");
        return;
    }
    
    var _savePath = DynamoDevProjectDirectory() + "notes\\" + _note + "\\" + _note + ".yy";
    if (!file_exists(_savePath))
    {
        __DynamoTrace("Cannot save buffer to Note asset \"", _note, "\", expected metadata file \"", _savePath, "\" does not exist");
        return;
    }
    
    var _savePath = DynamoDevProjectDirectory() + "notes\\" + _note + "\\" + _note + ".txt";
    __DynamoTrace("Saving buffer ", _buffer, " to \"", _savePath, "\"");
    buffer_save(_buffer, _savePath);
    
    _savePath = global.__dynamoWorkingDirectory + _nameHash + ".dynamo"
    __DynamoTrace("Saving buffer ", _buffer, " to \"", _savePath, "\"");
    buffer_save(_buffer, _savePath);
    
    var _hash = md5_file(_savePath);
    global.__dynamoNoteDictionary[$ _nameHash].__dataHash = _hash;
    __DynamoTrace("Updated Note asset record for \"", _note, "\" (data hash = ", _hash, ")");
}

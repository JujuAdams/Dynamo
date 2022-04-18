/// Saves a string (synchronously) to the named Note asset in the project
/// If the note does not exist then this function will fail
/// This function will do nothing if DYNAMO_DEV_MODE is set to <false> or the game is *not* being run from the IDE
/// 
/// @param string     String to save to the Note asset
/// @param noteAsset  Note asset to save to. If the Note doesn't exist then this function will fail

function DynamoDevSaveNoteString(_string, _note)
{
    if (!__DYNAMO_DEV_MODE) return;
    
    var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    DynamoDevSaveNoteBuffer(_buffer, _note);
    buffer_delete(_buffer);
}

/// Returns a string containing Note asset data
/// If loading failed, this function will either throw an exception (for fatal errors) or it will return an empty string
/// 
/// @param name          Name of the Note asset to target
/// @param [default=""]  Value to return if the buffer cannot be loaded. Defaults to an empty string

function DynamoNoteString(_name, _default = "")
{
    //Try to read the buffer associated with this note
    var _buffer = DynamoNoteBuffer(_name);
    
    //If there was an issue (usually the note doesn't exist) return an empty string
    if (_buffer == undefined) return _default;
    
    //Once we have the buffer, read out a string and return it
    var _string = buffer_read(_buffer, buffer_text);
    buffer_delete(_buffer);
    
    return _string;
}
/// Returns a string containing Note asset data
/// If loading failed, this function will either throw an exception (for fatal errors) or it will return an empty string
/// 
/// @param name    Name of the Note asset to target

function DynamoNoteString(_name)
{
    var _buffer = DynamoNoteBuffer(_name);
    
    if (_buffer < 0) return "";
    
    var _string = buffer_read(_buffer, buffer_text);
    buffer_delete(_buffer);
    
    return _string;
}
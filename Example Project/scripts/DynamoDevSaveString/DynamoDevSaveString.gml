/// Saves a string (synchronously) to the project's datafilesDynamo directory
/// This function will do nothing if DYNAMO_DEV_MODE is set to <false> or the game is *not* being run from the IDE
/// 
/// @param string  String to save to the file
/// @param path    Path for the file to save, relative to the datafilesDynamo directory in your project's root directory

function DynamoDevSaveString(_string, _path)
{
    if (!__DYNAMO_DEV_MODE) return;
    
    var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    DynamoDevSaveBuffer(_buffer, _path);
    buffer_delete(_buffer);
}

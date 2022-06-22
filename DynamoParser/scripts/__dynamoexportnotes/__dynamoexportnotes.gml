/// @param directory

function __DynamoExportNotes(_directory)
{
    //Verify we can find __DynamoConfig()
    var _path = _directory + "scripts/__dynamoconfig/__dynamoconfig.gml";
    
    if (!file_exists(_path))
    {
        __DynamoTrace("\"", _path, "\" not found, dynamic variables will not be available");
        return;
    }
    
    //Load up __DynamoConfig() as a buffer and search for DYNAMO_LIVE_ASSETS
    var _buffer = buffer_load(_path);
    var _string = buffer_read(_buffer, buffer_string);
    
    var _enabled = true;
    
    //Find the DYNAMO_ENABLED macro and figure out what value it has
    var _startPos = string_pos("DYNAMO_ENABLED", _string);
    if (_startPos <= 0) __DynamoError("Could not find DYNAMO_ENABLED macro in __DynamoConfig()");
    _startPos += string_length("DYNAMO_ENABLED");
    var _endPos = string_pos_ext("\n", _string, _startPos);
    var _substring = string_copy(_string, _startPos, _endPos - _startPos)
    
    if (string_pos("false", _substring) > 0)
    {
        _enabled = false;
    }
    else if (string_pos("true", _substring) <= 0)
    {
        __DynamoError("Illegal value for macro DYNAMO_ENABLED (found \"", _substring, "\", expecting <true> or <false>)");
    }
    
    //Don't do any work if we don't have to!
    if (!_enabled) return;
    
    __DynamoFindNotes(_directory);
    
    //Export Notes that we found
    var _buffer = buffer_create(1024, buffer_grow, 1);
    var _count = array_length(global.__dynamoNoteArray);
    buffer_write(_buffer, buffer_u64, _count);
    
    array_sort(global.__dynamoNoteArray, true); //Prettify the output a bit
    var _i = 0;
    repeat(_count)
    {
        var _note = global.__dynamoNoteArray[_i];
        var _noteBuffer = _note.__buffer;
        
        buffer_write(_buffer, buffer_string, _note.__name);
        buffer_write(_buffer, buffer_string, _note.__hash);
        buffer_write(_buffer, buffer_u64, buffer_get_size(_note.__buffer));
        
        //Resize the buffer if necessary
        if (buffer_tell(_buffer) + buffer_get_size(_noteBuffer) > buffer_get_size(_buffer))
        {
            buffer_resize(_buffer, buffer_tell(_buffer) + buffer_get_size(_noteBuffer));
        }
        
        buffer_copy(_noteBuffer, 0, buffer_get_size(_noteBuffer), _buffer, buffer_tell(_buffer));
        buffer_seek(_buffer, buffer_seek_relative, buffer_get_size(_noteBuffer));
        
        ++_i;
    }
    
    //Compress the buffer and save it into the project's Included Files
    var _compressedBuffer = buffer_compress(_buffer, 0, buffer_tell(_buffer));
    buffer_delete(_buffer);
    buffer_save(_compressedBuffer, _directory + "datafiles/DynamoData");
    buffer_delete(_compressedBuffer);
}
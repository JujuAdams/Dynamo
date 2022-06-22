function __DynamoReadNoteData()
{
    var _sourceBuffer = buffer_load("DynamoData");
    var _buffer = buffer_decompress(_sourceBuffer);
    buffer_delete(_sourceBuffer);
    
    var _header = buffer_read(_buffer, buffer_string);
    if (_header != "Dynamo") __DynamoError("Invalid header in data file");
    
    var _version = buffer_read(_buffer, buffer_string);
    if (_version != __DYNAMO_VERSION) __DynamoError("Version mismatch in data file (found ", _version, ", expected ", __DYNAMO_VERSION, ")");
    
    var _noteCount = buffer_read(_buffer, buffer_u64);
    var _i = 0;
    repeat(_noteCount)
    {
        var _noteName = buffer_read(_buffer, buffer_string);
        var _noteHash = buffer_read(_buffer, buffer_string);
        var _noteSize = buffer_read(_buffer, buffer_u64);
        
        var _noteBuffer = buffer_create(_noteSize, buffer_fixed, 1);
        buffer_copy(_buffer, buffer_tell(_buffer), _noteSize, _noteBuffer, 0);
        buffer_seek(_buffer, buffer_seek_relative, _noteSize);
        var _watcher = new __DynamoClassNote(_noteName, _noteHash, _noteBuffer);
        
        ++_i;
    }
    
    buffer_delete(_buffer);
}
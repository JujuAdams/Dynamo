function DynamoBuffer(_name)
{
    var _path = DynamoPath(_name);
    var _buffer = buffer_load(_path);
    
    if (global.__dynamoRunningFromIDE && !DYNAMO_FORCE_LOAD_FROM_BINARY)
    {
        //
    }
    else if (DYNAMO_COMPRESS)
    {
        var _compressedBuffer = _buffer;
        var _buffer = buffer_decompress(_compressedBuffer);
        buffer_delete(_compressedBuffer);
    }
    
    return _buffer;
}

function DynamoString(_name)
{
    var _buffer = DynamoBuffer(_name);
    var _string = buffer_read(_buffer, buffer_text);
    buffer_delete(_buffer);
    
    return _string;
}
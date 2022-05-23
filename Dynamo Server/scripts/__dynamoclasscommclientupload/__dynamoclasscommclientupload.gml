function __DynamoClassCommClientUpload(_owner, _token, _buffer) constructor
{
    __owner  = _owner;
    __token  = _token;
    __buffer = _buffer;
    
    static __ReceivePacket = function(_buffer, _offset, _size)
    {
        
    }
    
    static __Destroy = function()
    {
        if (__buffer != undefined)
        {
            buffer_delete(__buffer);
            __buffer = undefined;
        }
    }
}
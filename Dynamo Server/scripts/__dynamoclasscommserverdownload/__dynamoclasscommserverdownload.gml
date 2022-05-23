function __DynamoClassCommServerDownload(_owner, _token, _filename, _deviceIdent) constructor
{
    __owner       = _owner;
    __token       = _token;
    __filename    = _filename;
    __deviceIdent = _deviceIdent;
    
    __buffer = undefined;
    
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
function __DynamoClassCommServerUpload(_owner, _token, _filename, _totalSize, _packetCount) constructor
{
    __owner = _owner;
    __token = _token;
    
    __filename    = _filename;
    __totalSize   = _totalSize;
    __packetCount = _packetCount;
    
    __buffer = buffer_create(__totalSize, buffer_fixed, 1);
    __packetHistoryArray = array_create(__packetCount, false);
    
    static __ReceivePacket = function(_buffer, _offset, _size, _filename, _totalSize, _packetIndex, _packetCount)
    {
        if (__packetHistoryArray[_packetIndex]) return; //Already received this part of the buffer
    }
    
    static __ReceiveConfirm = function(_packetIndex)
    {
        __packetHistoryArray[@ _packetIndex] = true;
    }
    
    static __EndStep = function()
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
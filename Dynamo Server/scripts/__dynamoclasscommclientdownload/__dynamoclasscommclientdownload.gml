function __DynamoClassCommClientDownload(_owner, _token, _filename) constructor
{
    __owner = _owner;
    __token = _token;
    
    __filename    = _filename;
    __totalSize   = undefined;
    __packetCount = undefined;
    
    __buffer              = undefined;
    __packetHistoryArray  = undefined;
    __packetReceivedCount = 0;
    
    __lastReceivedPacket = current_time;
    
    static __ReceivePacket = function(_buffer, _packetOffset, _packetSize, _totalSize, _packetIndex, _packetCount)
    {
        if (__totalSize == undefined)
        {
            //Set up a buffer when we're given a valid size
            __totalSize = _totalSize;
            __buffer = buffer_create(__totalSize, buffer_fixed, 1);
        }
        else if (__totalSize != _totalSize)
        {
            //Validate total buffer size
            __DynamoError("Total size for download of \"", __filename, "\" changed");
        }
        
        if (__packetCount == undefined)
        {
            //Set up a packet history array when we're given a valid packet count
            __packetCount = _totalSize;
            __packetHistoryArray = array_create(__packetCount, false);
        }
        else if (__packetCount != _totalSize)
        {
            //Validate packet count
            __DynamoError("Packet count for download of \"", __filename, "\" changed");
        }
        
        if (__packetHistoryArray[_packetIndex])
        {
            //Already received this packet
            __SendConfirm(_packetIndex);
            return;
        }
        
        //New packet!
        __packetHistoryArray[@ _packetIndex] = true;
        __packetReceivedCount++;
        
        //Tell the server to stop sending this particular packet
        __SendConfirm(_packetIndex);
        
        //Copy the packet across into our
        buffer_copy(_buffer, _packetOffset, _packetSize, __buffer, _packetIndex*__DYNAMO_LAN_PACKET_SIZE);
        
        //Note down when we last received a packet. This is used for timeouts
        __lastReceivedPacket = current_time;
    }
    
    static __SendConfirm = function(_packetIndex)
    {
        __owner.__Send([__token, _packetIndex], global.__dynamoCommExpectedServerIdent);
    }
    
    static __EndStep = function()
    {
        //TODO - Build timeout system
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
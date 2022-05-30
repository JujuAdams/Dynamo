function __DynamoClassFile(_directory, _localPath) constructor
{
    static __type = __DYNAMO_TYPE_FILE;
    
    _directory = string_replace_all(_directory, "\\", "/");
    _localPath = string_replace_all(_localPath, "\\", "/");
    
    __path = _directory + _localPath;
    __localPath = string_replace(_localPath, "datafiles/", "");
    
    __contentStub   = true;
    __contentHash   = undefined;
    __contentBuffer = undefined;
    
    static __Track = function()
    {
        var _name = __GetName();
        array_push(global.__dynamoTrackingArray, _name);
        global.__dynamoTrackingStruct[$ _name] = self;
    }
    
    static __ContentEnsure = function(_dontCheckHash = true)
    {
        var _foundHash = (_dontCheckHash && (__contentHash != undefined) && !__contentStub)? __contentHash : __DynamoFileHash(__path);
        if (_foundHash != __contentHash)
        {
            __contentHash = _foundHash;
            
            __contentBuffer = __DynamoLoadBuffer(__path);
            if (__contentBuffer != undefined) __contentStub = false;
        }
        
        return (__contentBuffer != undefined);
    }
    
    static __ContentCheckForChanges = function()
    {
        return (__DynamoFileHash(__path) != __contentHash);
    }
    
    static __Check = function()
    {
        return __ContentEnsure(false);
    }
    
    static __BufferLoad = function()
    {
        if (!__ContentEnsure(false)) return false;
        return __contentBuffer;
    }
    
    static __BufferSave = function(_buffer, _internalDuplicate = true)
    {
        if (__contentBuffer != undefined) buffer_delete(__contentBuffer);
        
        if (_internalDuplicate)
        {
            var _oldBuffer = _buffer;
            _buffer = buffer_create(buffer_get_size(_oldBuffer), buffer_grow, 1);
            buffer_copy(_oldBuffer, 0, buffer_get_size(_oldBuffer), _buffer, 0);
        }
        
        __contentBuffer = _buffer;
        
        buffer_save(_buffer, __contentBuffer);
        
        __contentHash = __DynamoFileHash(__path);
        __contentStub = false;
    }
    
    static __GetName = function()
    {
        return __localPath;
    }
    
    static toString = function()
    {
        return __GetName();
    }
}
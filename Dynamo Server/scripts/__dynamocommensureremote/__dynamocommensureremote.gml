function __DynamoCommEnsureRemote(_serverMode, _deviceIdent)
{
    var _remote = global.__dynamoCommRemoteDictionary[$ _deviceIdent];
    
    if (is_struct(_remote))
    {
        if (_remote.__serverMode != _serverMode)
        {
            __DynamoError("Remote device \"", _deviceIdent, "\" already exists but is the wrong class");
        }
    }
    else
    {
        _remote = new __DynamoCommRemoteClass(_serverMode, _deviceIdent);
        
        global.__dynamoCommRemoteDictionary[$ _deviceIdent] = _remote;
        array_push(global.__dynamoCommRemoteArray, _deviceIdent);
    }
    
    return _remote;
}
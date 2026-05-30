// Feather disable all
/// Returns whether the Included File on disk has changed since the last time DynamoFileChanged()
/// was called (targetting that Included File).
/// 
/// If your game isn't running from the IDE or DYNAMO_ENABLED is set to <false> this function will
/// always return <false>.
/// 
/// @param path

function DynamoFileChanged(_path)
{
    if (not DYNAMO_RUNNING) return false;
    
    static _fileStruct = __DynamoState().__fileStruct;
    
    var _tracker = _fileStruct[$ _path];
    if (_tracker == undefined) __DynamoError("\"", _path, "\" hasn't been added with DynamoFile()");
    
    return _tracker.__HasChanged();
}

/// @param path

function DynamoFileForceLoad(_path)
{
    __DynamoInitialize();
    
    var _tracker = global.__dynamoFileStruct[$ _path];
    if (_tracker == undefined) __DynamoError("\"", _path, "\" hasn't been added with DynamoWatchFile()");
    
    _tracker.__Load();
}
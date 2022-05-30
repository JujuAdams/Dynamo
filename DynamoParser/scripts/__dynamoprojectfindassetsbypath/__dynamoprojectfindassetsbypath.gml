/// @param projectJSON
/// @param directory
/// @param pathSearchPrefix
/// @param classConstructor

function __DynamoProjectFindAssetsByPath(_projectJSON, _directory, _pathSearchPrefix, _classConstructor)
{
    if (!__DYNAMO_DEV_MODE) return;
    
    var _length = string_length(_pathSearchPrefix);
    
    var _outputArray = [];
    
    var _resourcesArray = _projectJSON.resources;
    var _i = 0;
    repeat(array_length(_resourcesArray))
    {
        var _resourceStruct = _resourcesArray[_i].id;
        var _path = _resourceStruct.path;
        if (string_copy(_path, 1, _length) == _pathSearchPrefix) array_push(_outputArray, new _classConstructor(_directory + _path));
        ++_i;
    }
    
    if (DYNAMO_VERBOSE) __DynamoTrace("Found ", array_length(_outputArray), " assets with path prefix \"", _pathSearchPrefix, "\"");
    
    return _outputArray;
}
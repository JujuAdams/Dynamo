/// @param projectJSON
/// @param directory
/// @param pathSearchPrefix

function __DynamoProjectFindAssetsByPath(_projectJSON, _directory, _pathSearchPrefix)
{
    if (!__DYNAMO_DEV_MODE) return;
    
    var _outputArray = [];
    
    var _resourcesArray = _projectJSON.resources;
    var _i = 0;
    repeat(array_length(_resourcesArray))
    {
        var _resourceStruct = _resourcesArray[_i].id;
        var _path = _resourceStruct.path;
        if (string_copy(_path, 1, 7) == _pathSearchPrefix) array_push(_outputArray, new __DynamoClassScript(_directory + _path));
        ++_i;
    }
    
    return _outputArray;
}
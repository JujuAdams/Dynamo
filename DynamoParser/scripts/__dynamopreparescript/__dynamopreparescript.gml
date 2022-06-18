function __DynamoPrepareScript(_name, _directory, _gmlFilename)
{
    var _gmlPath = _directory + _gmlFilename;
    if (!file_exists(_gmlPath)) __DynamoError("Could not find \"", _gmlPath, "\"");
    __DynamoPrepareGMLFile(_name, _gmlFilename);
}
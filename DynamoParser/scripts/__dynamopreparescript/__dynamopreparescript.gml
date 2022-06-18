function __DynamoPrepareScript(_name, _relativeDirectory, _absoluteDirectory, _gmlFilename)
{
    var _absolutePath = _absoluteDirectory + _gmlFilename;
    var _relativePath = _relativeDirectory + _gmlFilename;
    if (!file_exists(_absolutePath)) __DynamoError("Could not find \"", _absolutePath, "\"");
    __DynamoPrepareGMLFile(_name, _relativePath, _absolutePath, "__dynamo_" + _name + "_var");
}
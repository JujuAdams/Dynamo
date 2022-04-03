function __DynamoMainProjectJSON(_directory)
{
    //Try to find a project file in this directory
    var _count = 0;
    var _file = file_find_first(_directory + "*.yyp", 0);
    var _projectPath = _directory + _file;
    
    while(_file != "")
    {
        ++_count;
        _file = file_find_next();
    }
    
    file_find_close();
    
    //Report errors if we cannot find 
    if (_count <= 0)
    {
        __DynamoError("No project file (.yyp) found in \"", _directory, "\"");
        return undefined;
    }
    else if (_count > 1)
    {
        __DynamoError("More than project file (.yyp) found in \"", _directory, "\"");
        return undefined;
    }
    
    try
    {
        var _projectBuffer = buffer_load(_projectPath);
        var _string = buffer_read(_projectBuffer, buffer_text);
        buffer_delete(_projectBuffer);
    }
    catch(_error)
    {
        __DynamoError("Failed to load project file \"", _projectPath, "\"");
        return undefined;
    }
    
    __DynamoTrace("Loaded \"", _projectPath, "\"");
    
    try
    {
        var _json = json_parse(_string);
    }
    catch(_error)
    {
        __DynamoError("Failed to parse JSON in project file \"", _projectPath, "\"");
        return undefined;
    }
    
    __DynamoTrace("Parsed main project file");
    
    var _resourceType = _json[$ "resourceType"];
    if (_resourceType != "GMProject")
    {
        __DynamoError(".yyp file \"", _projectPath, "\" not recognised as a main project JSON\nResource type was \"", _resourceType, "\"");
        return undefined;
    }
    
    return _json;
}
function __DynamoParseMainProjectJSON(_directory)
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
        __DynamoError("No main project file (.yyp) found in \"", _directory, "\"\nPlease check that \"Disable file system sandbox\" is enabled in Game Options");
        return;
    }
    else if (_count > 1)
    {
        __DynamoError("More than .yyp file found in \"", _directory, "\"");
        return;
    }
    
    try
    {
        var _projectBuffer = buffer_load(_projectPath);
        var _string = buffer_read(_projectBuffer, buffer_text);
        buffer_delete(_projectBuffer);
    }
    catch(_error)
    {
        __DynamoError("Failed to load main project file \"", _projectPath, "\"");
        return;
    }
    
    __DynamoTrace("Loaded \"", _projectPath, "\"");
    
    try
    {
        var _json = json_parse(_string);
    }
    catch(_error)
    {
        __DynamoError("Failed to parse JSON in main project file \"", _projectPath, "\"");
        return;
    }
    
    __DynamoTrace("Parsed main project file");
    
    var _resourceType = _json[$ "resourceType"];
    if (_resourceType != "GMProject")
    {
        __DynamoError(".yyp file \"", _projectPath, "\" not recognised as a main project JSON\nResource type was \"", _resourceType, "\"");
        return;
    }
    
    return _json;
}
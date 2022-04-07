function __DynamoManifestNotesArray(_path)
{
    global.__dynamoNoteDictionary = {};
    var _array = [];
    
    if (!file_exists(_path))
    {
        __DynamoError("Could not find manifest at \"", _path, "\"\nPlease ensure Dynamo has been set up by running dynamo.exe in the project's root directory");
        return;
    }
    
    __DynamoTrace("Loading manifest at \"", _path, "\"");
    
    var _directory = filename_dir(_path) + "\\";
    __DynamoTrace("Chose directory as \"", _directory, "\"");
    
    try
    {
        var _manifestBuffer = buffer_load(_path);
    }
    catch(_error)
    {
        __DynamoError("Failed to load manifest \"", _manifestBuffer, "\"");
        return;
    }
    
    var _header = buffer_read(_manifestBuffer, buffer_string);
    if (_header != "Dynamo")
    {
        __DynamoError("Header string incorrect, manifest may be corrupted\nFound \"", _header, "\"\nExpecting \"Dynamo\"");
        return;
    }
    
    var _version = buffer_read(_manifestBuffer, buffer_string);
    if (_version != __DYNAMO_VERSION)
    {
        __DynamoError("Version mismatch. Please re-export binaries\nFound \"", _version, "\"\nExpecting \"", __DYNAMO_VERSION, "\"");
        return;
    }
    
    var _count = buffer_read(_manifestBuffer, buffer_u64);
    __DynamoTrace("Manifest has ", _count, " note(s)");
    
    repeat(_count)
    {
        var _nameHash = buffer_read(_manifestBuffer, buffer_string);
        __DynamoTrace("Found name hash \"", _nameHash, "\"");
        
        var _note = new __DynamoClassNote(undefined, _directory + _nameHash + ".dynamo", _nameHash);
        array_push(_array, _note);
    }
    
    __DynamoTrace("Parsed manifest");
    
    return _array;
}
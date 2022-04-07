/// Returns a buffer containing Note asset data
/// If loading failed, this function will either throw an exception (for fatal errors) or it will return -1
/// 
/// @param name    Name of the Note asset to target

function DynamoNoteBuffer(_name)
{
    //Guarantee we're initialized
    __DynamoInit();
    
    //And guarantee we have a manifest too
    __DynamoEnsureNoteDictionary();
    
    //Hash this note's name and check if we've seen a .dynamo file with that name
    var _nameHash = __DynamoNameHash(_name);
    
    if (!variable_struct_exists(global.__dynamoNoteDictionary, _nameHash))
    {
        __DynamoError("Could not find Note \"", _name, "\" in manifest (via hash as \"", _nameHash, "\")");
        return -1;
    }
    
    //We know that the note exists so let's read it!
    var _path = global.__dynamoNoteDictionary[$ _nameHash].__sourcePath;
    if (!file_exists(_path))
    {
        //Oh dear, we don't have a .dynamo file for this note for some reason
        if (__DYNAMO_DEV_MODE)
        {
            __DynamoTrace("Warning! \"", _path, "\" could not be found\nThis may indicate that \"Disable file system sandbox\" needs to be enabled in Game Options, or the Note asset has been deleted whilst this application has been running");
        }
        else
        {
            __DynamoError("\"", _path, "\" could not be found");
        }
        
        return -1;
    }
    
    //Try to load the .dynamo file and return an ID if we're successful
    try
    {
        var _buffer = buffer_load(_path);
    }
    catch(_error)
    {
        __DynamoError("Failed to load \"", _path, "\"");
        return -1;
    }
    
    if (!__DYNAMO_DEV_MODE && DYNAMO_COMPRESS)
    {
        var _compressedBuffer = _buffer;
        var _buffer = buffer_decompress(_compressedBuffer);
        buffer_delete(_compressedBuffer);
    }
    
    
    return _buffer;
}

/// Returns a buffer containing Note asset data
/// If loading failed, this function will either throw an exception (for fatal errors) or it will return <undefined>
/// 
/// @param name    Name of the Note asset to target

function DynamoNoteBuffer(_name)
{
    //Hash this note's name and check if we've seen a .dynamo file with that name
    var _nameHash = md5_string_utf8(_name);
    
    //We know that the note exists so let's read it!
    var _path = working_directory + _nameHash + ".dynamo";
    if (!file_exists(_path))
    {
        //Oh dear, we don't have a .dynamo file for this note for some reason
        __DynamoTrace("Warning! .dynamo file for Note asset \"", _name, "\" could not be found (path=", _path, ")");
        return undefined;
    }
    
    //Try to load the .dynamo file and return an ID if we're successful
    try
    {
        var _buffer = buffer_load(_path);
    }
    catch(_error)
    {
        __DynamoTrace("Error! Failed to load \"", _path, "\" (error=", _error, ")");
        return undefined;
    }
    
    return _buffer;
}

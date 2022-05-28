/// @param path

function __DynamoFileHash(_path)
{
    try
    {
        return md5_file(_path);
    }
    catch(_error)
    {
        __DynamoTrace("Warning! Could not calculate hash for \"", _path, "\"\n", _error);
        return undefined;
    }
}
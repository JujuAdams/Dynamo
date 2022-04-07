function __DynamoRecursiveFileSearch(_directory, _result)
{
    var _directories = [];
    
    //Search through this directory
    var _file = undefined;
    while(true)
    {
        //On Linux the attribute argument is ignored, and everything that we can read is returned (even directories with a proper pattern).
        //This doesn't affect this library in particular but good to keep that in mind.
        _file = (_file == undefined)? file_find_first(_directory + "*.*", fa_directory) : file_find_next();
        if (_file == "") break;
        
        //Anything that ends in .dynamo doesn't need to be indexed
        if (filename_ext(_file) != ".dynamo")
        {
            if (directory_exists(_directory + _file))
            {
                //Process this directory
                var _path = _directory + _file + "\\";
                
                if (variable_struct_exists(_result, _path))
                {
                    __DynamoTrace("Warning! Already seen directory \"", _path, "\", skipping this instance to avoid a loop");
                }
                else
                {
                    array_push(_directories, _path);
                    _result[$ _path] = new __DynamoClassFile(_path, true);
                }
            }
            else
            {
                //Add this matching file to the output dictionary
                var _path = _directory + _file;
                _result[$ _path] = new __DynamoClassFile(_path, false);
            }
        }
    }
    
    file_find_close();
    
    //Now handle the directories
    var _i = 0;
    repeat(array_length(_directories))
    {
        __DynamoRecursiveFileSearch(_directories[_i], _result);
        ++_i;
    }
    
    return _result;
}
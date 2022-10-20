function __DynamoFindNotes(_directory)
{
    _directory += "notes/";
    
	if (os_type ==os_windows)
	{
		var _file = file_find_first(_directory + "*.*", fa_directory);
	}
	else
	{
		var _file = file_find_first(_directory + "*", fa_directory);
	}
	
    while(_file != "")
    {
        var _path = _directory + _file + "/";
        if (directory_exists(_path))
        {
            var _yyPath  = _path + _file + ".yy";
            var _txtPath = _path + _file + ".txt";
            
            if (file_exists(_yyPath))
            {
                //Grab
                var _buffer = buffer_load(_yyPath);
                var _string = buffer_read(_buffer, buffer_text);
                buffer_delete(_buffer);
                var _json = json_parse(_string);
                
                var _name = _json.name;
                
                if (variable_struct_exists(_json, "tags"))
                {
                    var _tags = _json.tags;
                    var _accept = true;
                    var _i = 0;
                    repeat(array_length(_tags))
                    {
                        var _tag = _tags[_i];
                        if (string_lower(_tag) == "dynamo ignore")
                        {
                            _accept = false;
                            break;
                        }
                        
                        ++_i;
                    }
                }
                
                if (_accept)
                {
                    if (file_exists(_txtPath))
                    {
                        var _buffer = buffer_load(_txtPath);
                        array_push(global.__dynamoNoteArray, {
                            __name:   _name,
                            __hash:   __DynamoFileHash(_txtPath),
                            __buffer: _buffer,
                        });
                    }
                    else
                    {
                        var _buffer = buffer_create(0, buffer_fixed, 1);
                        array_push(global.__dynamoNoteArray, {
                            __name:   _name,
                            __hash:   "d41d8cd98f00b204e9800998ecf8427e",
                            __buffer: _buffer,
                        });
                    }
                }
            }
        }
        
        _file = file_find_next();
    }
    
    file_find_close();
}
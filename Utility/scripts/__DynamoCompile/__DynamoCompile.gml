function __DynamoCompile(_directory)
{
    __DynamoTrace("Compiling project in \"", _directory, "\"");
    
    var _projectJSON = __DynamoMainProjectJSON(_directory);
    if (_projectJSON == undefined)
    {
        __DynamoTrace("Failed to verify main project file");
        return;
    }
    
    __DynamoTrace("Loading notes from .yyp");
    
    var _dictionary = {};
    
    var _resourcesArray = _projectJSON[$ "resources"];
    if (_resourcesArray != undefined)
    {
        var _i = 0;
        repeat(array_length(_resourcesArray))
        {
            var _resourceStruct = _resourcesArray[_i].id;
            var _txtPath = filename_change_ext(_resourceStruct.path, ".txt");
            var _yyPath  = filename_change_ext(_resourceStruct.path, ".yy");
            var _name    = _resourceStruct.name;
            
            if ((string_copy(_txtPath, 1, 6) == "notes/") && !variable_struct_exists(_dictionary, _name))
            {
                var _ignore = false;
                
                //Discover if this asset has a "dynamo ignore" tag
                var _yyBuffer = buffer_load(_directory + _yyPath);
                var _yyString = buffer_read(_yyBuffer, buffer_string);
                buffer_delete(_yyBuffer);
                
                var _yyJSON = json_parse(_yyString);
                var _tagsArray = _yyJSON[$ "tags"];
                if (is_array(_tagsArray))
                {
                    var _i = 0;
                    repeat(array_length(_tagsArray))
                    {
                        var _tag = string_lower(_tagsArray[_i]);
                        if (_tag == "dynamo ignore")
                        {
                            _ignore = true;
                            break;
                        }
                        
                        ++_i;
                    }
                }
                
                if (_ignore)
                {
                    __DynamoTrace("Ignored \"", _name, "\"");
                }
                else
                {
                    //Save out this asset to the target datafiles folder
                    var _nameHash = __DynamoNameHash(_name);
                    _dictionary[$ _name] = _nameHash;
                    
                    if (file_exists(_directory + _txtPath))
                    {
                        var _txtBuffer = buffer_load(_directory + _txtPath);
                    }
                    else
                    {
                        var _txtBuffer = buffer_create(1, buffer_fixed, 1);
                    }
                    
                    var _outputPath = _directory + "datafiles\\dynamo_" + _nameHash;
                    __DynamoBufferSave(_txtBuffer, _outputPath);
                    __DynamoTrace("Saved \"", _name, "\" to \"", _outputPath + "\"");
                }
            }
            
            ++_i;
        }
    }
    
    //Output manifest
    var _nameArray = variable_struct_get_names(_dictionary);
    var _count = array_length(_nameArray);
    
    __DynamoTrace(_count, " note(s) exported");
    
    var _manifestBuffer = buffer_create(1024, buffer_grow, 1);
    buffer_write(_manifestBuffer, buffer_string, "Dynamo");
    buffer_write(_manifestBuffer, buffer_string, __DYNAMO_VERSION);
    buffer_write(_manifestBuffer, buffer_string, __DYNAMO_DATE);
    buffer_write(_manifestBuffer, buffer_u64, _count);
    
    var _i = 0;
    repeat(_count)
    {
        var _name = _nameArray[_i];
        var _nameHash = _dictionary[$ _name];
        buffer_write(_manifestBuffer, buffer_string, _nameHash);
        ++_i;
    }
    
    var _outputPath = _directory + "datafiles\\dynamo_manifest";
    __DynamoBufferSave(_manifestBuffer, _outputPath, buffer_tell(_manifestBuffer));
    __DynamoTrace("Saved manifest to \"", _outputPath + "\"");
    
    //Done!
    __DynamoTrace("Compilation of project in \"", _directory, "\" complete");
}
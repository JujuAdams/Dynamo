function __DynamoMainProjectNotesDictionary(_projectJSON, _directory)
{
    __DynamoTrace("Searching for notes in main project JSON");
    
    var _dictionary = {};
    
    var _resourcesArray = _projectJSON[$ "resources"];
    if (_resourcesArray != undefined)
    {
        var _i = 0;
        repeat(array_length(_resourcesArray))
        {
            var _resourceStruct = _resourcesArray[_i].id;
            var _path = _resourceStruct.path;
            var _name = _resourceStruct.name;
            
            if (string_copy(_path, 1, 6) == "notes/")
            {
                if (variable_struct_exists(_dictionary, _name))
                {
                    __DynamoTrace("Warning! Already found \"", _name, "\"");
                }
                else
                {
                    _path = _directory + _path;
                    
                    //Discover if this asset has a "dynamo ignore" tag
                    var _yyPath = filename_change_ext(_path, ".yy");
                    var _yyBuffer = buffer_load(_yyPath);
                    var _yyString = buffer_read(_yyBuffer, buffer_string);
                    buffer_delete(_yyBuffer);
                    
                    var _ignore = false;
                    var _yyJSON = json_parse(_yyString);
                    var _tagsArray = _yyJSON[$ "tags"];
                    if (is_array(_tagsArray))
                    {
                        var _j = 0;
                        repeat(array_length(_tagsArray))
                        {
                            var _tag = string_lower(_tagsArray[_j]);
                            if (_tag == "dynamo ignore")
                            {
                                _ignore = true;
                                break;
                            }
                            
                            ++_j;
                        }
                    }
                    
                    if (_ignore)
                    {
                        __DynamoTrace("Found note asset \"", _name, "\", but it has been set to ignored");
                    }
                    else
                    {
                        __DynamoTrace("Found note asset \"", _name, "\"");
                        var _note = new __DynamoClassNote(_name, filename_change_ext(_path, ".txt"), undefined);
                        _dictionary[$ _note.__nameHash] = _note;
                    }
                }
            }
            
            ++_i;
        }
    }
    
    __DynamoTrace("Found ", variable_struct_names_count(_dictionary), " note(s)");
    
    return _dictionary;
}
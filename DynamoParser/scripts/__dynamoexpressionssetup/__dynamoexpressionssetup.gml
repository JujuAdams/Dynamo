/// @param directory

function __DynamoExpressionsSetup(_directory)
{
    global.__dynamoBackupArray = [];
    
    //Verify we can find __DynamoConfig()
    var _path = _directory + "scripts/__dynamoconfig/__dynamoconfig.gml";
    
    if (!file_exists(_path))
    {
        __DynamoTrace("\"", _path, "\" not found, dynamic variables will not be available");
        return;
    }
    
    //This array will contain names of assets that we find in __DynamoConfig()
    //Having assets specified like this is a lot faster than reading the whole project and looking for tags
    var _assetArray = [];
    
    //Load up __DynamoConfig() as a buffer and search for DYNAMO_LIVE_ASSETS
    var _buffer = buffer_load(_path);
    var _string = buffer_read(_buffer, buffer_string);
    
    var _pos = string_pos("DYNAMO_LIVE_ASSETS", _string);
    if (_pos <= 0)
    {
        __DynamoError("DYNAMO_LIVE_ASSETS not found in __DynamoConfig()");
        return;
    }
    
    //Move the buffer to just after the macro
    //We want to start looking for an array (of assets) immediately following the macro
    var _substring = string_copy(_string, 1, _pos + string_length("DYNAMO_LIVE_ASSETS"));
    buffer_seek(_buffer, buffer_seek_start, string_byte_length(_substring) - 1);
    
    //Search for the opening [ for the array
    repeat(buffer_get_size(_buffer) - buffer_tell(_buffer))
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        if (_byte <= 32)
        {
            //Whitespace, do nothing
        }
        else if (_byte == 91) // [
        {
            break;
        }
        else
        {
            __DynamoError("Syntax error whilst reading DYNAMO_LIVE_ASSETS\nCould not find start of array");
        }
    }
    
    //Extract asset names and store them for handling later
    var _nameStart = 0;
    var _inName = false;
    var _lookingForComma = false;
    repeat(buffer_get_size(_buffer) - buffer_tell(_buffer))
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        if (_byte <= 32)
        {
            if (_inName)
            {
                _inName = false;
                _lookingForComma = true;
                
                //Extract the asset name if we find a space
                //Bit of a weird formatting choice to have whitespace before a comma but it's technically legal...
                var _name = __DynamoBufferReadString(_buffer, _nameStart, buffer_tell(_buffer)-2);
                array_push(_assetArray, _name);
            }
        }
        else if (_byte == 44) // ,
        {
            if (_inName)
            {
                _inName = false;
                
                //We've seen a comma, extract the asset name and carry on
                var _name = __DynamoBufferReadString(_buffer, _nameStart, buffer_tell(_buffer)-2);
                array_push(_assetArray, _name);
            }
            else
            {
                if (!_lookingForComma) __DynamoError("Syntax error whilst reading DYNAMO_LIVE_ASSETS\nUnexpected comma found");
                _lookingForComma = false;
            }
        }
        else
        {
            if (_byte == 34) // "
            {
                __DynamoError("Syntax error whilst reading DYNAMO_LIVE_ASSETS\nUnexpected double quote found");
            }
            else if (_byte == 93)
            {
                break;
            }
            else
            {
                if (_lookingForComma) __DynamoError("Syntax error whilst reading DYNAMO_LIVE_ASSETS\nExpecting comma, found alphanumeric character");
            
                if (!_inName)
                {
                    _inName = true;
                    _nameStart = buffer_tell(_buffer)-1;
                }
            }
        }
    }
    
    //Now iterate over all the assets we found and prepare that for use with Dynamo
    //We don't know, on the face of it, what datatype these assets are so we're going to search for them
    var _i = 0;
    repeat(array_length(_assetArray))
    {
        var _name = _assetArray[_i];
        var _lowerName = string_lower(_name);
        
        var _searchDirectory = "objects/" + _lowerName + "/";
        if (directory_exists(_directory + _searchDirectory))
        {
            __DynamoPrepareObject(_name, _searchDirectory, _directory + _searchDirectory, _lowerName + ".yy");
        }
        else
        {
            _searchDirectory = "scripts/" + _lowerName + "/";
            if (directory_exists(_directory + _searchDirectory))
            {
                __DynamoPrepareScript(_name, _searchDirectory, _directory + _searchDirectory, _lowerName + ".gml");
            }
            else
            {
                __DynamoError("Could not determine type of asset \"", _name, "\"");
            }
        }
        
        ++_i;
    }
    
    //Save our expression data into the project too
    var _path = _directory + "scripts/__dynamoexpressiondata/__dynamoexpressiondata.gml";
    if (!file_exists(_path))
    {
        __DynamoError("Could not export Dynamo expressions to \"", _path, "\"\nPlease check that this script exists in your project");
        return;
    }
    
    __DynamoTrace("Exporting Dynamo expressions and trackable files to \"", _path, "\"");
    
    //File header
    var _buffer = buffer_create(1024, buffer_grow, 1);
    buffer_write(_buffer, buffer_text, "/// Autogenerated by Dynamo ");
    buffer_write(_buffer, buffer_text, __DYNAMO_VERSION);
    buffer_write(_buffer, buffer_text, "    ");
    buffer_write(_buffer, buffer_text, date_datetime_string(date_current_datetime()));
    buffer_write(_buffer, buffer_text, "\n\n");
    
    //Write the trackable files first
    buffer_write(_buffer, buffer_text, "function __DynamoExpressionData()\n{\n");
    
    array_sort(global.__dynamoExpressionFileArray, true); //Prettify the output a bit
    
    var _i = 0;
    repeat(array_length(global.__dynamoExpressionFileArray))
    {
        var _data = global.__dynamoExpressionFileArray[_i];
        buffer_write(_buffer, buffer_text, "    __DynamoExpressionFileWatch(\"");
        buffer_write(_buffer, buffer_text, _data.__name);
        buffer_write(_buffer, buffer_text, "\", \"");
        buffer_write(_buffer, buffer_text, _data.__variablePrefix);
        buffer_write(_buffer, buffer_text, "\", \"");
        buffer_write(_buffer, buffer_text, _data.__path);
        buffer_write(_buffer, buffer_text, "\", \"");
        buffer_write(_buffer, buffer_text, _data.__hash);
        buffer_write(_buffer, buffer_text, "\");\n");
        ++_i;
    }
    
    //Then the variable expressions
    buffer_write(_buffer, buffer_text, "    \n    global.__dynamoExpressionDict = {\n");
    
    var _nameArray = variable_struct_get_names(global.__dynamoExpressionDict);
    array_sort(_nameArray, true); //Prettify the output a bit
    
    var _i = 0;
    repeat(array_length(_nameArray))
    {
        var _name  = _nameArray[_i];
        var _value = global.__dynamoExpressionDict[$ _name];
        
        //Sanitize!
        _name  = string_replace_all(_name,  "\"", "\\\"");
        _value = string_replace_all(_value, "\"", "\\\"");
        
        buffer_write(_buffer, buffer_text, "        "); //We wrap the variable identifier in quote marks just in case a space sneaks in
        buffer_write(_buffer, buffer_text, _name);
        buffer_write(_buffer, buffer_text, ": __DynamoExpressionCompile(\"");
        buffer_write(_buffer, buffer_text, _value);
        buffer_write(_buffer, buffer_text, "\"),\n");
        
        ++_i;
    }
    
    buffer_write(_buffer, buffer_text, "    };\n}");
    buffer_save(_buffer, _path);
    buffer_delete(_buffer);
    
    __DynamoTrace(array_length(global.__dynamoExpressionFileArray), " files and ", variable_struct_names_count(global.__dynamoExpressionDict), " expressions were exported");
    
    //Save out a batch file that contains instructions for the OS to restore the backup (unchanged) copies of files
    var _batchPath = _directory + "DynamoRestoreBackups.bat";
    var _buffer = buffer_create(1024, buffer_grow, 1);
    
    //Header, with apology
    buffer_write(_buffer, buffer_text, ":: Autogenerated by Dynamo ");
    buffer_write(_buffer, buffer_text, __DYNAMO_VERSION);
    buffer_write(_buffer, buffer_text, "    ");
    buffer_write(_buffer, buffer_text, date_datetime_string(date_current_datetime()));
    buffer_write(_buffer, buffer_text, "\r\n:: The CD command before DEL works around issues with spaces in the path (cmd is dumb)\r\n\r\n");
    
    var _i = 0;
    repeat(array_length(global.__dynamoBackupArray))
    {
        var _data = global.__dynamoBackupArray[_i];
        var _name = _data.__name;
        var _originalPath = _data.__originalPath;
        var _backupPath = _data.__backupPath;
        
        //A bit hard to read because all the lines are squashed together but this
        // - Adds a :: comment
        // - Uses XCOPY to copy the backup over the actual source file
        // - CDs into the correct directory
        // - Deletes the old backup file
        buffer_write(_buffer, buffer_text, ":: Restore ");
        buffer_write(_buffer, buffer_text, _name);
        buffer_write(_buffer, buffer_text, "\r\nxcopy \"");
        buffer_write(_buffer, buffer_text, _backupPath);
        buffer_write(_buffer, buffer_text, "\" \"");
        buffer_write(_buffer, buffer_text, _originalPath);
        buffer_write(_buffer, buffer_text, "\" /f /c /y\r\ncd \"");
        buffer_write(_buffer, buffer_text, filename_dir(_backupPath));
        buffer_write(_buffer, buffer_text, "\"\r\ndel /q \"");
        buffer_write(_buffer, buffer_text, filename_name(_backupPath));
        buffer_write(_buffer, buffer_text, "\"\r\n\r\n");
        
        ++_i;
    }
    
    buffer_save(_buffer, _batchPath);
    buffer_delete(_buffer);
}
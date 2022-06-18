/// @param directory

function __DynamoVariablesParserSetup(_directory)
{
    var _path = _directory + "scripts/__dynamoconfig/__dynamoconfig.gml";
    var _backupPath = _directory + "scripts/__dynamoconfig/__dynamoconfig_backup.gml";
    
    if (!file_exists(_path))
    {
        __DynamoTrace("\"", _path, "\" not found, dynamic variables will not be available");
        return;
    }
    
    __DynamoAddRestorableFile("__dynamoconfig.gml", _path, _backupPath);
    
    var _foundAssets = [];
    
    var _buffer = buffer_load(_path);
    var _string = buffer_read(_buffer, buffer_string);
    
    var _pos = string_pos("DYNAMO_LIVE_ASSETS", _string);
    if (_pos <= 0)
    {
        __DynamoError("DYNAMO_LIVE_ASSETS not found in __DynamoConfig()");
        return;
    }
    
    var _substring = string_copy(_string, 1, _pos + string_length("DYNAMO_LIVE_ASSETS"));
    buffer_seek(_buffer, buffer_seek_start, string_byte_length(_substring) - 1);
    
    var _batchOp = new __DynamoBufferBatch();
    _batchOp.FromBuffer(_buffer);
    
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
                
                _batchOp.Insert(buffer_tell(_buffer)-1, "\"");
                var _name = __DynamoBufferReadString(_buffer, _nameStart, buffer_tell(_buffer)-2);
                array_push(_foundAssets, _name);
            }
        }
        else if (_byte == 44) // ,
        {
            if (_inName)
            {
                _inName = false;
                
                _batchOp.Insert(buffer_tell(_buffer)-1, "\"");
                var _name = __DynamoBufferReadString(_buffer, _nameStart, buffer_tell(_buffer)-2);
                array_push(_foundAssets, _name);
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
                    _batchOp.Insert(_nameStart, "\"");
                }
            }
        }
    }
    
    buffer_save(_batchOp.GetBuffer(), _path);
    _batchOp.Destroy();
}
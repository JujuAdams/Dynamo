function __DynamoParseGML(_inBuffer)
{
    var _oldTell = buffer_tell(_inBuffer);
    buffer_seek(_inBuffer, buffer_seek_start, 0);
    var _parser = new __DynamoParseGMLInner(_inBuffer, buffer_get_size(_inBuffer));
    buffer_seek(_inBuffer, buffer_seek_start, _oldTell);
}

function __DynamoParseGMLInner(_buffer, _bufferSize) constructor
{
    targetArray = [];
    
    buffer = _buffer;
    buffer_size = _bufferSize;
    line = 1;
    
    var _bracketDepth = 0;
    var _prevToken = undefined;
    var _doubleBracketValidDict = [];
    var _doubleBracketTokenDict = [];
    
    var _tokenArray       = [];
    var _bufferStartArray = [];
    
    //TODO - Also handle #hexcodes $hexcodes 0xhexcodes int64
    while(buffer_tell(buffer) < _bufferSize)
    {
        token           = undefined;
        token_is_real   = false;
        token_is_string = false;
        token_is_symbol = false;
        
        _bufferStartArray[array_length(_tokenArray)] = buffer_tell(buffer);
        read_token();
        
        //If we failed to read a token, continue
        if (!is_string(token)) continue;
        
        if (token_is_symbol)
        {
            if (token == "(")
            {
                ++_bracketDepth;
                _doubleBracketValidDict[_bracketDepth] = (_prevToken == "(");
                _doubleBracketTokenDict[_bracketDepth] = array_length(_tokenArray);
            }
            else if (token == ")")
            {
                if (_prevToken == ")")
                {
                    if (_doubleBracketValidDict[_bracketDepth+1])
                    {
                        array_push(targetArray, {
                            startIndex: _doubleBracketTokenDict[_bracketDepth+1]+1,
                            endIndex:   array_length(_tokenArray)-2,
                        });
                    }
                }
                else if (_doubleBracketTokenDict[_bracketDepth] > _doubleBracketTokenDict[_bracketDepth-1] + 1)
                {
                    _doubleBracketValidDict[_bracketDepth-1] = false;
                }
                
                --_bracketDepth;
            }
        }
        
        array_push(_tokenArray, token);
        var _prevToken = token;
    }
    
    array_push(_tokenArray, buffer_tell(buffer)-1);
    
    show_debug_message(_tokenArray);
    show_debug_message(_bufferStartArray);
    show_debug_message(targetArray);
    
    show_debug_message(__DynamoBufferReadString(buffer, _bufferStartArray[0], _bufferStartArray[targetArray[0].startIndex-1]));
    show_debug_message(__DynamoBufferReadString(buffer, _bufferStartArray[targetArray[0].endIndex+1], _bufferStartArray[targetArray[1].startIndex-1]));
    show_debug_message(__DynamoBufferReadString(buffer, _bufferStartArray[targetArray[1].endIndex+1], _bufferStartArray[array_length(_bufferStartArray)-1]));
    
    static read_token = function()
    {
        var _token_start      = undefined;
        var _in_string        = false;
        var _in_line_comment  = false;
        var _in_block_comment = false;
        
        while(buffer_tell(buffer) < buffer_size)
        {
            var _value = buffer_read(buffer, buffer_u8);
            
            if (_value == 10) line++;
            
            if (_in_string)
            {
                if ((_value == 34) && (buffer_peek(buffer, buffer_tell(buffer) - 2, buffer_u8) != 92))
                {
                    buffer_poke(buffer, buffer_tell(buffer) - 1, buffer_u8, 0x0);
                    buffer_seek(buffer, buffer_seek_start, _token_start + 1); //Skip the leading double quote
                    token = buffer_read(buffer, buffer_string);
                    buffer_poke(buffer, buffer_tell(buffer) - 1, buffer_u8, _value);
                    
                    token_is_string = true;
                    token_is_symbol = false;
                    break;
                }
            }
            else if (_in_line_comment)
            {
                if (_value == 10) _in_line_comment = false;
            }
            else if (_in_block_comment)
            {
                if ((_value == 47) && (buffer_peek(buffer, buffer_tell(buffer) - 2, buffer_u8) == 42))
                {
                    _in_block_comment = false;
                }
            }
            else
            {
                if (_token_start == undefined)
                {
                    if (_value > 32)
                    {
                        if ((_value == 47) && (buffer_peek(buffer, buffer_tell(buffer), buffer_u8) == 47))
                        {
                            //Line comment
                            _in_line_comment = true;
                        }
                        else if ((_value == 47) && (buffer_peek(buffer, buffer_tell(buffer), buffer_u8) == 42))
                        {
                            //Block comment
                            _in_block_comment = true;
                        }
                        else
                        {
                            _token_start = buffer_tell(buffer) - 1;
                            if (_value == 34) _in_string = true;
                            
                            if ((_value ==  40)  // (
                            ||  (_value ==  41)  // )
                            ||  (_value ==  42)  // *
                            ||  (_value ==  43)  // +
                            ||  (_value ==  44)  // ,
                            ||  (_value ==  45)  // -
                            ||  (_value ==  47)  // /
                            ||  (_value ==  58)  // :
                            ||  (_value ==  59)  // ;
                            ||  (_value ==  60)  // <
                            ||  (_value ==  61)  // =
                            ||  (_value ==  62)  // >
                            ||  (_value ==  63)  // ?
                            ||  (_value ==  64)  // @
                            ||  (_value ==  91)  // [
                            ||  (_value ==  93)  // ]
                            ||  (_value ==  94)  // ^
                            ||  (_value == 123)  // {
                            ||  (_value == 125)  // }
                            ||  (_value == 126)) // ~
                            {
                                token = chr(_value);
                                token_is_string = false;
                                token_is_symbol = true;
                                break;
                            }
                        }
                    }
                }
                else if ((_value <=  32)  // whitespace
                     ||  (_value ==  40)  // (
                     ||  (_value ==  41)  // )
                     ||  (_value ==  42)  // *
                     ||  (_value ==  43)  // +
                     ||  (_value ==  44)  // ,
                     ||  (_value ==  45)  // -
                     ||  (_value ==  47)  // /
                     ||  (_value ==  58)  // :
                     ||  (_value ==  59)  // ;
                     ||  (_value ==  60)  // <
                     ||  (_value ==  61)  // =
                     ||  (_value ==  62)  // >
                     ||  (_value ==  63)  // ?
                     ||  (_value ==  64)  // @
                     ||  (_value ==  91)  // [
                     ||  (_value ==  93)  // ]
                     ||  (_value ==  94)  // ^
                     ||  (_value == 123)  // {
                     ||  (_value == 125)  // }
                     ||  (_value == 126)) // }
                {
                    buffer_poke(buffer, buffer_tell(buffer) - 1, buffer_u8, 0x0);
                    buffer_seek(buffer, buffer_seek_start, _token_start);
                    token = buffer_read(buffer, buffer_string);
                    buffer_seek(buffer, buffer_seek_relative, -1);
                    buffer_poke(buffer, buffer_tell(buffer), buffer_u8, _value);
                    
                    token_is_string = false;
                    token_is_symbol = false;
                    break;
                }
            }
        }
        
        //Figure out if the token is a real value or not
        if (!token_is_string && !token_is_symbol)
        {
            try
            {
                token = real(token);
                token_is_real = true;
            }
            catch(_error)
            {
                token_is_real = false;
            }
        }
    }
}
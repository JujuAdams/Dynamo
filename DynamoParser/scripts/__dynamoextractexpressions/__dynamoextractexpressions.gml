function __DynamoExtractExpressions(_inBuffer)
{
    var _oldTell = buffer_tell(_inBuffer);
    buffer_seek(_inBuffer, buffer_seek_start, 0);
    var _parser = new __DynamoExtractExpressionsInner(_inBuffer, buffer_get_size(_inBuffer));
    buffer_seek(_inBuffer, buffer_seek_start, _oldTell);
    return _parser.targetArray;
}

function __DynamoExtractExpressionsInner(_buffer, _bufferSize) constructor
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
        token_is_string = false;
        token_is_symbol = false;
        
        _bufferStartArray[array_length(_bufferStartArray)] = buffer_tell(buffer);
        read_token();
        
        //If we failed to read a token, continue
        if (token == undefined) continue;
        
        if (token_is_symbol)
        {
            if (token == "(")
            {
                array_push(_doubleBracketValidDict, (_prevToken == "("));
                array_push(_doubleBracketTokenDict, array_length(_tokenArray));
            }
            else if (token == ")")
            {
                if (_prevToken == ")")
                {
                    if (_doubleBracketValidDict[array_length(_doubleBracketValidDict)-1])
                    {
                        var _startIndex = _doubleBracketTokenDict[_bracketDepth+1]+1;
                        var _endIndex   = array_length(_tokenArray)-2;
                        
                        var _targetTokenCount = 1 + _endIndex - _startIndex;
                        var _targetTokenArray = array_create(_targetTokenCount);
                        array_copy(_targetTokenArray, 0, _tokenArray, _startIndex, _targetTokenCount);
                        
                        array_push(targetArray, {
                            startIndex:  _startIndex,
                            endIndex:    _endIndex,
                            startPos:    undefined,
                            endPos:      undefined,
                            innerString: undefined,
                        });
                    }
                }
                
                array_pop(_doubleBracketValidDict);
                array_pop(_doubleBracketTokenDict);
            }
        }
        
        array_push(_tokenArray, token);
        var _prevToken = token;
    }
    
    array_push(_bufferStartArray, buffer_tell(buffer)-1);
    
    var _i = 0;
    repeat(array_length(targetArray))
    {
        with(targetArray[_i])
        {
            startPos    = _bufferStartArray[startIndex-1];
            endPos      = _bufferStartArray[endIndex+1  ];
            innerString = __DynamoBufferReadString(other.buffer, startPos+1, endPos-1);
        }
        
        ++_i;
    }
    
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
                if (_token_start == undefined) //TODO - Move this outside the loop
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
                    break;
                }
            }
        }
    }
}
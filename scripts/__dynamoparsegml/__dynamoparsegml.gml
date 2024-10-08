// Feather disable all

function __DynamoParseGML(_string, _scope = {}, _aliasStruct = {})
{
    var _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
    buffer_write(_buffer, buffer_string, _string);
    var _data = __DynamoBufferReadGML(_buffer, 0, buffer_get_size(_buffer), _scope, _aliasStruct, true);
    buffer_delete(_buffer);
    return _data;
}

function __DynamoBufferReadGML(_buffer, _offset, _size, _scope = {}, _aliasStruct = {}, _allowAllAssets = false)
{
    static _globalTokenStruct = __DynamoState().__globalTokenStruct;
    
    static _symbolPrecedenceStruct = (function()
    {
        var _struct = {};
        _struct[$ "["] = 1;
        _struct[$ "]"] = 1;
        _struct[$ "{"] = 1;
        _struct[$ "}"] = 1;
        
        _struct[$ "new"                   ] = 2;
        _struct[$ __DYNAMO_GML_OP_NEGATIVE] = 2;
        _struct[$ __DYNAMO_GML_OP_POSITIVE] = 2;
        
        _struct[$  "!"] =  2;
        _struct[$  "~"] =  2;
        _struct[$  "*"] =  3;
        _struct[$  "/"] =  3;
        _struct[$  "%"] =  3;
        _struct[$  "+"] =  4;
        _struct[$  "-"] =  4;
        _struct[$ "<<"] =  5;
        _struct[$ ">>"] =  5;
        _struct[$  "<"] =  6;
        _struct[$ "<="] =  6;
        _struct[$  ">"] =  6;
        _struct[$ ">="] =  6;
        _struct[$ "=="] =  7;
        _struct[$ "!="] =  7;
        _struct[$  "&"] =  8;
        _struct[$  "^"] =  9;
        _struct[$  "|"] = 10;
        _struct[$ "&&"] = 11;
        _struct[$ "^^"] = 11.5; //Not a C operator, squeezed in here to match native GML
        _struct[$ "||"] = 12;
        
        _struct[$ __DYNAMO_GML_OP_TERNARY] = 13;
        _struct[$  ":"] = 13;
        _struct[$  "?"] = 13;
        
        _struct[$  "="] = 14;
        
        return _struct;
    })();
    
    static _symbolAssociativityStruct = (function()
    {
        var _struct = {};
        _struct[$  "["] = true;  //Left
        _struct[$  "]"] = true;  //Left
        _struct[$  "{"] = true;  //Left
        _struct[$  "}"] = true;  //Left
        
        _struct[$ "new"                   ] = false; //Right
        _struct[$ __DYNAMO_GML_OP_NEGATIVE] = false; //Right
        _struct[$ __DYNAMO_GML_OP_POSITIVE] = false; //Right
        
        _struct[$  "!"] = false; //Right
        _struct[$  "~"] = false; //Right
        _struct[$  "*"] = true;  //Left
        _struct[$  "/"] = true;  //Left
        _struct[$  "%"] = true;  //Left
        _struct[$  "+"] = true;  //Left
        _struct[$  "-"] = true;  //Left
        _struct[$ "<<"] = true;  //Left
        _struct[$ ">>"] = true;  //Left
        _struct[$  "<"] = true;  //Left
        _struct[$ "<="] = true;  //Left
        _struct[$  ">"] = true;  //Left
        _struct[$ ">="] = true;  //Left
        _struct[$ "=="] = true;  //Left
        _struct[$ "!="] = true;  //Left
        _struct[$  "&"] = true;  //Left
        _struct[$  "^"] = true;  //Left
        _struct[$  "|"] = true;  //Left
        _struct[$ "&&"] = true;  //Left
        _struct[$ "^^"] = true;  //Left
        _struct[$ "||"] = true;  //Left
        
        _struct[$ __DYNAMO_GML_OP_TERNARY] = false; //Right
        _struct[$  ":"] = undefined; //Doesn't matter
        _struct[$  "?"] = false; //Right
        
        _struct[$  "="] = false; //Right
        
        return _struct;
    })();
    
    static _reorderArray    = [];
    static _opStack         = [];
    static _commaCountStack = [];
    static _evaluateStack   = [];
    
    if (GM_build_type == "run")
    {
        var _debugReorderArray    = _reorderArray;
        var _debugCommaCountStack = _commaCountStack;
        var _debugOpStackArray    = _opStack;
        var _debugEvaluateStack   = _evaluateStack;
    }
    
    //////////////////////
    //                  //
    // Step 1: Tokenize //
    //                  //
    //////////////////////
    
    var _oldOffset = buffer_tell(_buffer);
    buffer_seek(_buffer, buffer_seek_start, _offset);
    
    var _tokensArray = [];
    
    var _readStart   = 0;
    var _state       = __DYNAMO_GML_TOKEN_STATE.__UNKNOWN;
    var _nextState   = __DYNAMO_GML_TOKEN_STATE.__UNKNOWN;
    var _lastByte    = 0;
    var _new         = false;
    var _changeState = true;
    
    var _b = 0;
    repeat(_size)
    {
        var _byte = buffer_peek(_buffer, _b, buffer_u8);
        _nextState = (_byte == 0)? __DYNAMO_GML_TOKEN_STATE.__NULL : __DYNAMO_GML_TOKEN_STATE.__UNKNOWN;
        _changeState = true;
        _new = false;
        
        switch(_state)
        {
            case __DYNAMO_GML_TOKEN_STATE.__LINE_COMMENT:
                if (_lastByte == ord("\n")) //Newline
                {
                    _new = true;
                }
                else
                {
                    _nextState = __DYNAMO_GML_TOKEN_STATE.__LINE_COMMENT;
                }
            break;
            
            case __DYNAMO_GML_TOKEN_STATE.__BLOCK_COMMENT:
                if ((_lastByte == ord("/")) && (buffer_peek(_buffer, _b-2, buffer_u8) == ord("*"))) // */
                {
                    _new = true;
                }
                else
                {
                    _nextState = __DYNAMO_GML_TOKEN_STATE.__BLOCK_COMMENT;
                }
            break;
            
            case __DYNAMO_GML_TOKEN_STATE.__IDENTIFIER: //Identifier (variable/function)
                if ((_byte == ord("\"")) || (_byte == ord("%")) || (_byte == ord("&")) || (_byte == ord(")"))
                ||  (_byte == ord( "*")) || (_byte == ord("+")) || (_byte == ord(",")) || (_byte == ord("-"))
                ||  (_byte == ord( "/")) || (_byte == ord(":")) || (_byte == ord(";")) || (_byte == ord("<")) || (_byte == ord("="))
                ||  (_byte == ord( ">")) || (_byte == ord("?")) || (_byte == ord("[")) || (_byte == ord("]")) || (_byte == ord("^"))
                ||  (_byte == ord( "{")) || (_byte == ord("|")) || (_byte == ord("}")) || (_byte == ord("~")))
                {
                    _nextState = __DYNAMO_GML_TOKEN_STATE.__SYMBOL;
                }
                else if (_byte > 32) //Everything is permitted, except whitespace
                {
                    _nextState = __DYNAMO_GML_TOKEN_STATE.__IDENTIFIER;
                }
                
                
                if ((_state != _nextState) || (_lastByte == ord("("))) //Cheeky hack to find functions
                {
                    var _isSymbol   = false;
                    var _isLiteral  = false;
                    var _isFunction = (_lastByte == ord("(")); //Cheeky hack to find functions
                    var _isAsset    = false;
                    
                    //Just a normal keyboard/variable
                    buffer_poke(_buffer, _b, buffer_u8, 0);
                    buffer_seek(_buffer, buffer_seek_start, _readStart);
                    var _read = buffer_read(_buffer, buffer_string);
                    buffer_poke(_buffer, _b, buffer_u8, _byte);
                    
                    if (!_isFunction)
                    {
                        //Convert friendly human-readable operators into symbolic operators
                        switch(_read)
                        {
                            case "new":                          _isSymbol = true; break;
                            case "mod":       _read = "%";       _isSymbol = true; break;
                            case "and":       _read = "&&";      _isSymbol = true; break;
                            case "or" :       _read = "||";      _isSymbol = true; break;
                            case "xor" :      _read = "^^";      _isSymbol = true; break;
                            case "not":       _read = "!";       _isSymbol = true; break;
                            case "true":      _read = true;      _isLiteral = true; break;
                            case "false":     _read = false;     _isLiteral = true; break;
                            case "undefined": _read = undefined; _isLiteral = true; break;
                            case "infinity":  _read = infinity ; _isLiteral = true; break;
                        }
                    }
                    
                    if (_isSymbol)
                    {
                        array_push(_tokensArray,   __DYNAMO_GML_TOKEN_SYMBOL, _read, undefined);
                    }
                    else if (_isLiteral)
                    {
                        array_push(_tokensArray,   __DYNAMO_GML_TOKEN_LITERAL, _read, undefined);
                    }
                    else if (_isFunction)
                    {
                        _read = string_copy(_read, 1, string_length(_read)-1); //Trim off the open bracket
                        
                        if (_allowAllAssets)
                        {
                            try
                            {
                                var _asset = asset_get_index(_read);
                                if ((real(_asset) >= 0) && (asset_get_type(_read) != asset_unknown))
                                {
                                    _isAsset = true;
                                    _read = _asset;
                                }
                            }
                            catch(_error)
                            {
                                
                            }
                        }
                        
                        array_push(_tokensArray,   __DYNAMO_GML_TOKEN_FUNCTION, _read, undefined);
                        array_push(_tokensArray,   __DYNAMO_GML_TOKEN_SYMBOL,   "(",   undefined);
                    }
                    else
                    {
                        if (_allowAllAssets)
                        {
                            try
                            {
                                var _asset = asset_get_index(_read);
                                if ((real(_asset) >= 0) && (asset_get_type(_asset) != asset_unknown))
                                {
                                    _isAsset = true;
                                }
                            }
                            catch(_error)
                            {
                                
                            }
                        }
                        
                        if (_isAsset)
                        {
                            array_push(_tokensArray,   __DYNAMO_GML_TOKEN_VARIABLE, _asset, undefined);
                        }
                        else
                        {
                            array_push(_tokensArray,   __DYNAMO_GML_TOKEN_VARIABLE, _read, undefined);
                        }
                    }
                    
                    _new = true;
                    _nextState = __DYNAMO_GML_TOKEN_STATE.__UNKNOWN;
                }
            break;
            
            case __DYNAMO_GML_TOKEN_STATE.__STRING:
                if ((_byte == 0) || ((_byte == 34) && (_lastByte != 92))) //null "
                {
                    _changeState = false;
                    
                    if (_readStart < _b - 1)
                    {
                        buffer_poke(_buffer, _b, buffer_u8, 0);
                        buffer_seek(_buffer, buffer_seek_start, _readStart+1);
                        var _read = buffer_read(_buffer, buffer_string);
                        buffer_poke(_buffer, _b, buffer_u8, _byte);
                    }
                    else
                    {
                        var _read = "";
                    }
                    
                    array_push(_tokensArray,   __DYNAMO_GML_TOKEN_LITERAL, _read, undefined);
                    _new = true;
                }
                else
                {
                    _nextState = __DYNAMO_GML_TOKEN_STATE.__STRING;
                }
            break;
            
            case __DYNAMO_GML_TOKEN_STATE.__NUMBER:
                if (_byte == 46) //.
                {
                    _nextState = __DYNAMO_GML_TOKEN_STATE.__NUMBER;
                }
                else if ((_byte >= 48) && (_byte <= 57)) //0 1 2 3 4 5 6 7 8 9
                {
                    _nextState = __DYNAMO_GML_TOKEN_STATE.__NUMBER;
                }
                
                if (_state != _nextState)
                {
                    buffer_poke(_buffer, _b, buffer_u8, 0);
                    buffer_seek(_buffer, buffer_seek_start, _readStart);
                    var _read = buffer_read(_buffer, buffer_string);
                    buffer_poke(_buffer, _b, buffer_u8, _byte);
                    
                    try
                    {
                        _read = real(_read);
                    }
                    catch(_error)
                    {
                        __DynamoError("Could not convert \"", _read, "\" to a number");
                        return undefined;
                    }
                    
                    array_push(_tokensArray,   __DYNAMO_GML_TOKEN_LITERAL, _read, undefined);
                    
                    _new = true;
                }
            break;
            
            case __DYNAMO_GML_TOKEN_STATE.__SYMBOL:
                if (_byte == 61) //=
                {
                    if ((_lastByte == 33)  // !=
                    ||  (_lastByte == 42)  // *=
                    ||  (_lastByte == 43)  // +=
                    ||  (_lastByte == 45)  // +=
                    ||  (_lastByte == 47)  // /=
                    ||  (_lastByte == 60)  // <=
                    ||  (_lastByte == 61)  // ==
                    ||  (_lastByte == 62)) // >=
                    {
                        _nextState = __DYNAMO_GML_TOKEN_STATE.__SYMBOL;
                    }
                }
                else if ((_byte == 38) && (_lastByte == 38)) //&
                {
                    _nextState = __DYNAMO_GML_TOKEN_STATE.__SYMBOL;
                }
                else if ((_byte == 124) && (_lastByte == 124)) //|
                {
                    _nextState = __DYNAMO_GML_TOKEN_STATE.__SYMBOL;
                }
                
                if (_state != _nextState)
                {
                    buffer_poke(_buffer, _b, buffer_u8, 0);
                    buffer_seek(_buffer, buffer_seek_start, _readStart);
                    var _read = buffer_read(_buffer, buffer_string);
                    buffer_poke(_buffer, _b, buffer_u8, _byte);
                    
                    array_push(_tokensArray,   __DYNAMO_GML_TOKEN_SYMBOL, _read, undefined);
                    
                    _new = true;
                }
            break;
        }
        
        if (_changeState && (_nextState == __DYNAMO_GML_TOKEN_STATE.__UNKNOWN))
        {
            if (_byte == 33) //!
            {
                _nextState = __DYNAMO_GML_TOKEN_STATE.__SYMBOL;
            }
            else if ((_byte == 34) && (_lastByte != 92)) //"
            {
                _nextState = __DYNAMO_GML_TOKEN_STATE.__STRING;
            }
            else if ((_byte == 37) || (_byte == 38)) //% &
            {
                _nextState = __DYNAMO_GML_TOKEN_STATE.__SYMBOL;
            }
            else if ((_byte == 40) || (_byte == 41)) //( )
            {
                _nextState = __DYNAMO_GML_TOKEN_STATE.__SYMBOL;
            }
            else if ((_byte >= 42) && (_byte <= 46)) //* + , - .
            {
                _nextState = __DYNAMO_GML_TOKEN_STATE.__SYMBOL;
            }
            else if (_byte == 47) // /
            {
                var _nextByte = buffer_peek(_buffer, _b+1, buffer_u8);
                if (_nextByte == 47) // /
                {
                    _nextState = __DYNAMO_GML_TOKEN_STATE.__LINE_COMMENT;
                }
                else if (_nextByte == 42) // *
                {
                    _nextState = __DYNAMO_GML_TOKEN_STATE.__BLOCK_COMMENT;
                }
                else
                {
                    _nextState = __DYNAMO_GML_TOKEN_STATE.__SYMBOL;
                }
            }
            else if ((_byte >= 48) && (_byte <= 57)) //0 1 2 3 4 5 6 7 8 9
            {
                _nextState = __DYNAMO_GML_TOKEN_STATE.__NUMBER;
            }
            else if ((_byte >= 58) && (_byte <= 63))  //: ; < = > ?
            {
                _nextState = __DYNAMO_GML_TOKEN_STATE.__SYMBOL;
            }
            else if ((_byte >= 65) && (_byte <= 90)) //a b c...x y z
            {
                _nextState = __DYNAMO_GML_TOKEN_STATE.__IDENTIFIER;
            }
            else if (_byte == 91) //[
            {
                _nextState = __DYNAMO_GML_TOKEN_STATE.__SYMBOL;
            }
            else if (_byte == 93) //]
            {
                _nextState = __DYNAMO_GML_TOKEN_STATE.__SYMBOL;
            }
            else if (_byte == 94) //^
            {
                _nextState = __DYNAMO_GML_TOKEN_STATE.__SYMBOL;
            }
            else if (_byte == 95) //_
            {
                _nextState = __DYNAMO_GML_TOKEN_STATE.__IDENTIFIER;
            }
            else if ((_byte >= 97) && (_byte <= 122)) //A B C...X Y Z
            {
                _nextState = __DYNAMO_GML_TOKEN_STATE.__IDENTIFIER;
            }
            else if ((_byte >= 123) && (_byte <= 126)) // { | } ~
            {
                _nextState = __DYNAMO_GML_TOKEN_STATE.__SYMBOL;
            }
        }
        
        if (_new || (_state != _nextState)) _readStart = _b;
        _state = _nextState;
        if (_state == __DYNAMO_GML_TOKEN_STATE.__NULL) break;
        _lastByte = _byte;
        
        ++_b;
    }
    
    buffer_seek(_buffer, buffer_seek_start, _oldOffset);
    
    ///////////////////////////
    //                       //
    // Step 2: Shunting Yard //
    //                       //
    ///////////////////////////
    
    array_resize(_opStack, 0);
    array_resize(_commaCountStack, 0);
    array_resize(_reorderArray, 0);
    
    var _i = 0;
    repeat(array_length(_tokensArray) div 3)
    {
        var _tokenType  = _tokensArray[_i  ];
        var _tokenValue = _tokensArray[_i+1];
        
        if (_tokenType == __DYNAMO_GML_TOKEN_SYMBOL)
        {
            if (_tokenValue == ";")
            {
                var _j = array_length(_opStack) - 3;
                repeat(array_length(_opStack) div 3)
                {
                    array_push(_reorderArray,   _opStack[_j+1], _opStack[_j+2], undefined);
                    _j -= 3;
                }
                
                array_resize(_opStack, 0);
            }
            else if ((_tokenValue == "(") || (_tokenValue == "[") || (_tokenValue == "{"))
            {
                array_push(_commaCountStack, 0);
                array_push(_opStack,   infinity, _tokenType, _tokenValue);
            }
            else if (_tokenValue == ",")
            {
                if (_tokensArray[(_i-3)+1] == ",")
                {
                    array_push(_reorderArray, __DYNAMO_GML_TOKEN_LITERAL, undefined, undefined);
                }
                
                var _j = array_length(_opStack) - 3;
                repeat(array_length(_opStack) div 3)
                {
                    if (is_infinity(_opStack[_j])) break;
                    array_push(_reorderArray,   _opStack[_j+1], _opStack[_j+2], undefined);
                    _j -= 3;
                }
                
                if (_j < 0)
                {
                    __DynamoError("Invalid comma unencountered");
                }
                
                array_resize(_opStack, _j+3);
                
                _commaCountStack[array_length(_commaCountStack)-1] += 1;
            }
            else if ((_tokenValue == ")") || (_tokenValue == "]") || (_tokenValue == "}"))
            {
                if (array_length(_commaCountStack) <= 0)
                {
                    __DynamoError("Unexpected token \"", _tokenValue, "\"");
                }
                
                var _parameterCount = 1 + array_pop(_commaCountStack);
                
                if (_tokenValue == ")")
                {
                    var _matchingSymbol = "(";
                }
                else if (_tokenValue == "]")
                {
                    var _matchingSymbol = "[";
                }
                else if (_tokenValue == "}")
                {
                    var _matchingSymbol = "{";
                }
                
                var _j = array_length(_opStack) - 3;
                repeat(array_length(_opStack) div 3)
                {
                    var _opValue = _opStack[_j+2];
                    if (_opValue == _matchingSymbol) break;
                    
                    array_push(_reorderArray,   _opStack[_j+1], _opValue, undefined);
                    
                    _j -= 3;
                }
                
                if (_j < 0)
                {
                    __DynamoError("Mismatched brackets");
                }
                
                array_resize(_opStack, _j);
                
                //Handle function calls
                if (array_length(_opStack) > 0)
                {
                    var _j = array_length(_opStack)-3;
                    
                    //Retroactively set the parameter count to 0 if the two brackets are adjacent: func(), [], {}
                    var _prevToken = _tokensArray[(_i-3) + 1];
                    if (_prevToken == _matchingSymbol)
                    {
                        _parameterCount = 0;
                    }
                    else if ((_tokenValue == "]") || (_tokenValue == "}")) && (_prevToken == ",")
                    {
                        --_parameterCount;
                    }
                    
                    if (_tokenValue == ")")
                    {
                        if (_opStack[_j+1] == __DYNAMO_GML_TOKEN_FUNCTION)
                        {
                            array_push(_reorderArray,   __DYNAMO_GML_TOKEN_FUNCTION, _opStack[_j+2], _parameterCount);
                            array_resize(_opStack, _j);
                        }
                    }
                    else if (_tokenValue == "]")
                    {
                        array_push(_reorderArray,   __DYNAMO_GML_TOKEN_SYMBOL, __DYNAMO_GML_OP_ARRAY_LITERAL, _parameterCount);
                    }
                    else if (_tokenValue == "}")
                    {
                        array_push(_reorderArray,   __DYNAMO_GML_TOKEN_SYMBOL, __DYNAMO_GML_OP_STRUCT_LITERAL, _parameterCount);
                    }
                }
            }
            else if (_tokenValue == ":")
            {
                var _foundTernary = false;
                
                var _j = array_length(_opStack) - 3;
                repeat(array_length(_opStack) div 3)
                {
                    var _opValue = _opStack[_j+2];
                    
                    if (_opValue == "?")
                    {
                        _foundTernary = true;
                        break;
                    }
                    
                    if (_opValue == "{")
                    {
                        break;
                    }
                    
                    array_push(_reorderArray,   _opStack[_j+1], _opValue, undefined);
                    
                    _j -= 3;
                }
                
                if (_j < 0)
                {
                    __DynamoError(": used without ? or {");
                }
                
                if (_foundTernary)
                {
                    array_resize(_opStack, _j);
                    array_push(_opStack,   _symbolPrecedenceStruct[$ __DYNAMO_GML_OP_TERNARY], __DYNAMO_GML_TOKEN_SYMBOL, __DYNAMO_GML_OP_TERNARY);
                }
                else
                {
                    var _prevToken = array_length(_reorderArray)-3;
                    if ((_reorderArray[_prevToken] != __DYNAMO_GML_TOKEN_VARIABLE) && (_reorderArray[_prevToken] != __DYNAMO_GML_TOKEN_LITERAL))
                    {
                        __DynamoError("Token before \":\" could not be converted to a string");
                    }
                    
                    _reorderArray[_prevToken] = __DYNAMO_GML_TOKEN_LITERAL;
                }
            }
            else
            {
                if (_tokenValue == "-")
                {
                    if ((_i == 0) || ((_tokensArray[_i-3] == __DYNAMO_GML_TOKEN_SYMBOL) && (_tokensArray[(_i-3)+1] != ")")))
                    {
                        _tokenValue = __DYNAMO_GML_OP_NEGATIVE;
                    }
                }
                else if (_tokenValue == "+")
                {
                    if ((_i == 0) || ((_tokensArray[_i-3] == __DYNAMO_GML_TOKEN_SYMBOL) && (_tokensArray[(_i-3)+1] != ")")))
                    {
                        _tokenValue = __DYNAMO_GML_OP_POSITIVE;
                    }
                }
                else if (_tokenValue == "=")
                {
                    if (array_length(_reorderArray) < 3)
                    {
                        __DynamoError("\"=\" used without variable");
                    }
                    
                    if (_reorderArray[array_length(_reorderArray)-3] != __DYNAMO_GML_TOKEN_VARIABLE)
                    {
                        __DynamoError("Token before \"=\" not a variable");
                    }
                    
                    _reorderArray[array_length(_reorderArray)-3] = __DYNAMO_GML_TOKEN_LITERAL;
                }
                
                var _tokenPrecedence = _symbolPrecedenceStruct[$    _tokenValue];
                var _leftAssociative = _symbolAssociativityStruct[$ _tokenValue];
                
                if ((_tokenPrecedence == undefined) || (_leftAssociative == undefined))
                {
                    __DynamoError("Token \"", _tokenValue, "\" not recognised");
                }
                
                var _j = array_length(_opStack) - 3;
                repeat(array_length(_opStack) div 3)
                {
                    var _stackPrecedence = _opStack[_j];
                    
                    if ((_stackPrecedence < _tokenPrecedence) || (_leftAssociative && (_stackPrecedence == _tokenPrecedence)))
                    {
                        array_push(_reorderArray,   _opStack[_j+1], _opStack[_j+2], undefined);
                    }
                    else
                    {
                        break;
                    }
                    
                    _j -= 3;
                }
                
                array_resize(_opStack, _j+3);
                array_push(_opStack,   _tokenPrecedence, _tokenType, _tokenValue);
            }
        }
        else if (_tokenType == __DYNAMO_GML_TOKEN_FUNCTION)
        {
            array_push(_opStack,   infinity, _tokenType, _tokenValue);
        }
        else
        {
            array_push(_reorderArray,   _tokenType, _tokenValue, undefined);
        }
        
        _i += 3;
    }
    
    var _j = array_length(_opStack) - 3;
    repeat(array_length(_opStack) div 3)
    {
        array_push(_reorderArray,   _opStack[_j+1], _opStack[_j+2], undefined);
        _j -= 3;
    }
    
    //////////////////////
    //                  //
    // Step 3: Evaluate //
    //                  //
    //////////////////////
    
    array_resize(_evaluateStack, 0);
    
    if (array_length(_reorderArray) <= 0)
    {
        return undefined;
    }
        
    var _i = 0;
    repeat(array_length(_reorderArray) div 3)
    {
        var _tokenType  = _reorderArray[_i  ];
        var _tokenValue = _reorderArray[_i+1];
        
        if (_tokenType == __DYNAMO_GML_TOKEN_LITERAL)
        {
            array_push(_evaluateStack, _tokenValue);
        }
        else if (_tokenType == __DYNAMO_GML_TOKEN_SYMBOL)
        {
            if (_tokenValue == __DYNAMO_GML_OP_NEGATIVE)
            {
                array_push(_evaluateStack, -array_pop(_evaluateStack));
            }
            else if (_tokenValue == __DYNAMO_GML_OP_POSITIVE)
            {
                array_push(_evaluateStack, +array_pop(_evaluateStack));
            }
            else if (_tokenValue == "!")
            {
                array_push(_evaluateStack, !array_pop(_evaluateStack));
            }
            else if (_tokenValue == "~")
            {
                array_push(_evaluateStack, ~array_pop(_evaluateStack));
            }
            else if (_tokenValue == "+")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a + _b);
            }
            else if (_tokenValue == "-")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a - _b);
            }
            else if (_tokenValue == "*")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a * _b);
            }
            else if (_tokenValue == "/")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a / _b);
            }
            else if (_tokenValue == "%")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a % _b);
            }
            else if (_tokenValue == "<<")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a << _b);
            }
            else if (_tokenValue == ">>")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a >> _b);
            }
            else if (_tokenValue == ">")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a > _b);
            }
            else if (_tokenValue == ">=")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a >= _b);
            }
            else if (_tokenValue == "<")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a < _b);
            }
            else if (_tokenValue == "<=")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a <= _b);
            }
            else if (_tokenValue == "==")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a == _b);
            }
            else if (_tokenValue == "!=")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a != _b);
            }
            else if (_tokenValue == "&")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a & _b);
            }
            else if (_tokenValue == "^")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a ^ _b);
            }
            else if (_tokenValue == "|")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a | _b);
            }
            else if (_tokenValue == "&&")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a && _b);
            }
            else if (_tokenValue == "^^")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a ^^ _b);
            }
            else if (_tokenValue == "||")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                array_push(_evaluateStack, _a || _b);
            }
            else if (_tokenValue == __DYNAMO_GML_OP_TERNARY)
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                var _condition = array_pop(_evaluateStack);
                array_push(_evaluateStack, _condition? _a : _b);
            }
            else if (_tokenValue == __DYNAMO_GML_OP_ARRAY_LITERAL)
            {
                var _parameterCount = _reorderArray[_i+2];
                var _array = array_create(_parameterCount);
                
                var _j = _parameterCount-1;
                repeat(_parameterCount)
                {
                    _array[_j] = array_pop(_evaluateStack);
                    --_j;
                }
                
                array_push(_evaluateStack, _array);
            }
            else if (_tokenValue == __DYNAMO_GML_OP_STRUCT_LITERAL)
            {
                var _parameterCount = _reorderArray[_i+2];
                var _struct = {};
                
                var _j = _parameterCount-1;
                repeat(_parameterCount)
                {
                    var _value = array_pop(_evaluateStack);
                    var _name  = array_pop(_evaluateStack);
                    
                    _struct[$ _name] = _value;
                    
                    --_j;
                }
                
                array_push(_evaluateStack, _struct);
            }
            else if (_tokenValue == "=")
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                
                if (string_copy(_a, 1, 7) == "global.")
                {
                    variable_global_set(string_delete(_a, 1, 7), _b);
                }
                else
                {
                    _scope[$ _a] = _b;
                }
            }
            else if (_tokenValue == "new")
            {
                //Ignore
            }
            else
            {
                __DynamoError("Symbol \"", _tokenValue, "\" unsupported");
            }
        }
        else if (_tokenType == __DYNAMO_GML_TOKEN_VARIABLE)
        {
            var _value = _aliasStruct[$ _tokenValue];
            if (_value == undefined)
            {
                if (variable_struct_exists(_globalTokenStruct, _tokenValue))
                {
                    _value = _globalTokenStruct[$ _tokenValue]();
                }
                else if (not variable_struct_exists(_aliasStruct, _tokenValue))
                {
                    __DynamoError("Variable \"", _tokenValue, "\" has no alias");
                }
            }
            
            array_push(_evaluateStack, _value);
        }
        else if (_tokenType == __DYNAMO_GML_TOKEN_FUNCTION)
        {
            var _parameterCount = _reorderArray[_i+2];
            
            if (is_method(_tokenValue) || (not is_string(_tokenValue) && script_exists(real(_tokenValue))))
            {
                var _function = _tokenValue;
            }
            else
            {
                var _function = _aliasStruct[$ _tokenValue];
                if (_function == undefined)
                {
                    if (variable_struct_exists(_globalTokenStruct, _tokenValue))
                    {
                        _function = _globalTokenStruct[$ _tokenValue]();
                    }
                    else if (not variable_struct_exists(_aliasStruct, _tokenValue))
                    {
                        __DynamoError("Function \"", _tokenValue, "\" has no alias");
                    }
                }
            }
            
            var _constructor = false;
            if (_i < array_length(_reorderArray)-3)
            {
                if (_reorderArray[(_i+3) + 1] == "new")
                {
                    _constructor = true;
                }
            }
            
            if (_parameterCount == 0)
            {
                var _value = _constructor? new _function() : _function();
            }
            else if (_parameterCount == 1)
            {
                var _value = _constructor? new _function(array_pop(_evaluateStack)) : _function(array_pop(_evaluateStack));
            }
            else if (_parameterCount == 2)
            {
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                var _value = _constructor? new _function(_a, _b) : _function(_a, _b);
            }
            else if (_parameterCount == 3)
            {
                var _c = array_pop(_evaluateStack);
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                var _value = _constructor? new _function(_a, _b, _c) : _function(_a, _b, _c);
            }
            else if (_parameterCount == 4)
            {
                var _d = array_pop(_evaluateStack);
                var _c = array_pop(_evaluateStack);
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                var _value = _constructor? new _function(_a, _b, _c, _d) : _function(_a, _b, _c, _d);
            }
            else if (_parameterCount == 5)
            {
                var _e = array_pop(_evaluateStack);
                var _d = array_pop(_evaluateStack);
                var _c = array_pop(_evaluateStack);
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                var _value = _constructor? new _function(_a, _b, _c, _d, _e) : _function(_a, _b, _c, _d, _e);
            }
            else if (_parameterCount == 6)
            {
                var _f = array_pop(_evaluateStack);
                var _e = array_pop(_evaluateStack);
                var _d = array_pop(_evaluateStack);
                var _c = array_pop(_evaluateStack);
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                var _value = _constructor? new _function(_a, _b, _c, _d, _e, _f) : _function(_a, _b, _c, _d, _e, _f);
            }
            else if (_parameterCount == 7)
            {
                var _g = array_pop(_evaluateStack);
                var _f = array_pop(_evaluateStack);
                var _e = array_pop(_evaluateStack);
                var _d = array_pop(_evaluateStack);
                var _c = array_pop(_evaluateStack);
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                var _value = _constructor? new _function(_a, _b, _c, _d, _e, _f, _g) : _function(_a, _b, _c, _d, _e, _f, _g);
            }
            else if (_parameterCount == 8)
            {
                var _h = array_pop(_evaluateStack);
                var _g = array_pop(_evaluateStack);
                var _f = array_pop(_evaluateStack);
                var _e = array_pop(_evaluateStack);
                var _d = array_pop(_evaluateStack);
                var _c = array_pop(_evaluateStack);
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                var _value = _constructor? new _function(_a, _b, _c, _d, _e, _f, _g, _h) : _function(_a, _b, _c, _d, _e, _f, _g, _h);
            }
            else if (_parameterCount == 9)
            {
                var _i = array_pop(_evaluateStack);
                var _h = array_pop(_evaluateStack);
                var _g = array_pop(_evaluateStack);
                var _f = array_pop(_evaluateStack);
                var _e = array_pop(_evaluateStack);
                var _d = array_pop(_evaluateStack);
                var _c = array_pop(_evaluateStack);
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                var _value = _constructor? new _function(_a, _b, _c, _d, _e, _f, _g, _h, _i) : _function(_a, _b, _c, _d, _e, _f, _g, _h, _i);
            }
            else if (_parameterCount == 10)
            {
                var _j = array_pop(_evaluateStack);
                var _i = array_pop(_evaluateStack);
                var _h = array_pop(_evaluateStack);
                var _g = array_pop(_evaluateStack);
                var _f = array_pop(_evaluateStack);
                var _e = array_pop(_evaluateStack);
                var _d = array_pop(_evaluateStack);
                var _c = array_pop(_evaluateStack);
                var _b = array_pop(_evaluateStack);
                var _a = array_pop(_evaluateStack);
                var _value = _constructor? new _function(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j) : _function(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j);
            }
            else
            {
                __DynamoError("Unsupported number of arguments ", _parameterCount, " for function \"", _tokenValue, "\"");
            }
            
            array_push(_evaluateStack, _value);
        }
        
        _i += 3;
    }
    
    return _scope;
}
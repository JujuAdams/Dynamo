function __DynamoExpressionEvaluate(_local_scope, _expression)
{
    if (!is_struct(_expression)) return _expression;
    
    if (_expression.op == "var")
    {
        return undefined; //TODO
    }
    
    var _a = undefined;
    var _b = undefined;
    
    switch(_expression.op)
    {
        case "/":
        case "*":
        case "-":
        case "+":
            _a = __DynamoExpressionEvaluate(_local_scope, _expression.a);
            _b = __DynamoExpressionEvaluate(_local_scope, _expression.b);
        break;
        
        case "neg":
        case "paren":
        case "param":
            _a = __DynamoExpressionEvaluate(_local_scope, _expression.a);
        break;
        
        case "func":
            var _parameters = _expression.parameters;
            var _parameter_values = array_create(array_length(_parameters), undefined);
            var _p = 0;
            repeat(array_length(_parameters))
            {
                _parameter_values[@ _p] = __DynamoExpressionEvaluate(_local_scope, _parameters[_p]);
                ++_p;
            }
        break;
    }
    
    switch(_expression.op)
    {
        case "/": return _a / _b; break;
        case "*": return _a * _b; break;
        case "-": return _a - _b; break;
        case "+": return _a + _b; break;
        
        case "neg":   return -_a; break;
        case "paren": return  _a; break;
        case "param": return  _a; break;
        
        case "func":
            with (_local_scope)
            {
                var _method = global.__chatterboxFunctions[? _expression.name];
                if (is_method(_method))
                {
                    switch (array_length(_parameter_values))
                    {
                        //Reductio Ad Overmars
                        //"Every GameMaker game has the pyramid of doom"
                        case  0: return _method();
                        case  1: return _method(_parameter_values[0]);
                        case  2: return _method(_parameter_values[0], _parameter_values[1]);
                        case  3: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2]);
                        case  4: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3]);
                        case  5: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4]);
                        case  6: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5]);
                        case  7: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6]);
                        case  8: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7]);
                        case  9: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8]);
                        case 10: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9]);
                        case 11: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10]);
                        case 12: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11]);
                        case 13: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11], _parameter_values[12]);
                        case 14: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11], _parameter_values[12], _parameter_values[13]);
                        case 15: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11], _parameter_values[12], _parameter_values[13], _parameter_values[14]);
                        case 16: return _method(_parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11], _parameter_values[12], _parameter_values[13], _parameter_values[14], _parameter_values[15]);
                    }
                }
                else if (is_numeric(_method) && script_exists(_method))
                {
                    switch (array_length(_parameter_values))
                    {
                        //Reductio Ad Overmars
                        //"Every GameMaker game has the pyramid of doom"
                        case  0: return script_execute(_method);
                        case  1: return script_execute(_method, _parameter_values[0]);
                        case  2: return script_execute(_method, _parameter_values[0], _parameter_values[1]);
                        case  3: return script_execute(_method, _parameter_values[0], _parameter_values[1], _parameter_values[2]);
                        case  4: return script_execute(_method, _parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3]);
                        case  5: return script_execute(_method, _parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4]);
                        case  6: return script_execute(_method, _parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5]);
                        case  7: return script_execute(_method, _parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6]);
                        case  8: return script_execute(_method, _parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7]);
                        case  9: return script_execute(_method, _parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8]);
                        case 10: return script_execute(_method, _parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9]);
                        case 11: return script_execute(_method, _parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10]);
                        case 12: return script_execute(_method, _parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11]);
                        case 13: return script_execute(_method, _parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11], _parameter_values[12]);
                        case 14: return script_execute(_method, _parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11], _parameter_values[12], _parameter_values[13]);
                        case 15: return script_execute(_method, _parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11], _parameter_values[12], _parameter_values[13], _parameter_values[14]);
                        case 16: return script_execute(_method, _parameter_values[0], _parameter_values[1], _parameter_values[2], _parameter_values[3], _parameter_values[4], _parameter_values[5], _parameter_values[6], _parameter_values[7], _parameter_values[8], _parameter_values[9], _parameter_values[10], _parameter_values[11], _parameter_values[12], _parameter_values[13], _parameter_values[14], _parameter_values[15]);
                    }
                }
                else
                {
                    __DynamoError("Function \"", _expression.name, "\" could not be found");
                }
            }
            
            return undefined;
        break;
        
        default:
            __DynamoError("Operator \"", _expression.op, "\" unhandled");
        break;
    }
    
    return undefined;
}
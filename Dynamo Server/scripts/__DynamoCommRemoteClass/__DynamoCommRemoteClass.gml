function __DynamoCommRemoteClass(_serverMode, _ident) constructor
{
    __alive = true;
    
    __ident      = _ident;
    __serverMode = _serverMode;
    
    __lastReceive = current_time;
    
    if (__serverMode)
    {
        __DynamoTrace("New server found \"", __ident, "\"");
    }
    else
    {
        __DynamoTrace("New client found \"", __ident, "\"");
    }
    
    
    
    static __EndStep = function()
    {
        if (!__alive) return;
        
        if (current_time - __lastReceive > global.__dynamoCommTimeout)
        {
            __alive = false;
            __DynamoTrace("\"", self, "\" has timed out");
        }
    }
    
    static __Draw = function(_x, _y)
    {
        if (!__alive) return;
        
        matrix_stack_push(matrix_build(_x, _y, 0,    0, 0, 0,    1, 1, 1));
        matrix_set(matrix_world, matrix_stack_top());
        
        var _oldFont = draw_get_font();
        draw_set_font(__DynamoDebugFont);
        draw_text(0, 0, self);
        
        draw_rectangle(70, 2, lerp(70, 100, (current_time - __lastReceive) / global.__dynamoCommTimeout), 9, false);
        draw_rectangle(70, 2, 100, 9, true);
        
        draw_set_font(_oldFont);
        
        matrix_stack_pop();
        matrix_set(matrix_world, matrix_stack_top());
    }
    
    static toString = function()
    {
        return (__serverMode? "Server " : "Client ") + __ident;
    }
}
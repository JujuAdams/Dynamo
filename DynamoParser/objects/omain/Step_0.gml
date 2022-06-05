if (keyboard_check_pressed(ord("U")))
{
    var _i = 0;
    repeat(array_length(global.__dynamoGMLArray))
    {
        with(global.__dynamoGMLArray[_i])
        {
            __UpdateInternal();
            __CleanUp();
        }
        
        ++_i;
    }
}
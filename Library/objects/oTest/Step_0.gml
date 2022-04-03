if (keyboard_check_pressed(vk_f5))
{
    var _array = DynamoDevCheckForChanges();
}
else
{
    var _array = DynamoDevCheckForChangesOnFocus();
}

if (is_array(_array))
{
    show_message(DynamoString("TestNote"));
}

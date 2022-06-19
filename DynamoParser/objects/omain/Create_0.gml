if (__DynamoRunningFromIDE())
{
    if (debug_mode)
    {
        projectDirectory = "A:\\GitHub repos\\Mine\\Dynamo\\DynamoExample\\";
    }
    else
    {
        game_end();
        return;
    }
}
else
{
    projectDirectory = parameter_string(1);
}

alarm[0] = 10;
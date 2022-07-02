if ((os_type != os_windows) && (os_type != os_macosx))
{
	__DynamoError("Dynamo is not supported on this platform");
}

if (debug_mode)
{
	if (os_type == os_windows)
	{
		projectDirectory = "A:/GitHub repos/Mine/Dynamo/DynamoExample/";
	}
	else if (os_type == os_macosx)
	{
		projectDirectory = "/Users/jujuadams/Documents/GitHub/Dynamo/DynamoExample/";
	}
}
else
{
    projectDirectory = parameter_string(1);
}

alarm[0] = 10;
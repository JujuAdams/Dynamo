var _i = 0;
repeat(parameter_count())
{
	__DynamoTrace("param ", _i, ": \"", parameter_string(_i), "\"");
	++_i;
}

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
	if (os_type == os_windows)
	{
		projectDirectory = parameter_string(1);
	}
	else if (os_type == os_macosx)
	{
		projectDirectory = parameter_string(0);
	}
}

alarm[0] = (os_type == os_macosx)? 1 : 10;
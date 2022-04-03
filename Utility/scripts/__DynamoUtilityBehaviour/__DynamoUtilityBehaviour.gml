function __DynamoUtilityBehaviour()
{
    if (__DynamoRunningFromIDE())
    {
        __DynamoTrace("Running from IDE");
        
        if (__DYNAMO_TEST_MODE)
        {
            __DynamoLoud("Welcome to Dynamo by @jujuadams!\n\nThis is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE, "\n\nRunning in test mode...");
            __DynamoCompile("A:\\GitHub repos\\Mine\\Dynamo\\Library\\");
        }
        else
        {
            __DynamoLoud("Welcome to Dynamo by @jujuadams!\n\nThis is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE, "\n\nThis project must be compiled using the \"Package as Installer\" option before use.");
        }
    }
    else
    {
        __DynamoTrace("Running from from executable");
        
        //Clean up the weird broken parameter string that we might get passed
        var _i = 1;
        var _parameterString = "";
        repeat(parameter_count() - 1)
        {
            _parameterString += parameter_string(_i) + " ";
            ++_i;
        }
        
        var _pos = string_pos("-compile", _parameterString);
        if (_pos <= 0)
        {
            //No -compile, let's try to install!
            __DynamoLoud("Welcome to Dynamo by @jujuadams!\n\nThis is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE);
            __DynamoInstall(filename_dir(_parameterString) + "\\");
        }
        else
        {
            __DynamoCompile(filename_dir(string_copy(_parameterString, 1, _pos-1)) + "\\");
        }
    }
}
function __DynamoEnsureProjectDirectory()
{
    if (__DYNAMO_DEV_MODE && (global.__dynamoProjectDirectory == undefined))
    {
        if (!file_exists("projectDirectory.dynamo"))
        {
            __DynamoError("Could not find project directory link file\nPlease ensure Dynamo has been set up by running dynamo.exe in the project's root directory");
            return;
        }
        else
        {
            try
            {
                var _buffer = buffer_load("projectDirectory.dynamo");
            }
            catch(_error)
            {
                __DynamoError("Caught an exception whilst loading project directory link file");
            }
            
            if (_buffer < 0)
            {
                __DynamoError("Failed to load project directory link file");
            }
            
            global.__dynamoProjectDirectory = buffer_read(_buffer, buffer_text);
            buffer_delete(_buffer);
            
            //Trim off any invalid characters at the end of the project directory string
            var _i = string_length(global.__dynamoProjectDirectory);
            repeat(_i)
            {
                if (ord(string_char_at(global.__dynamoProjectDirectory, _i)) >= 32) break;
                --_i;
            }
            
            global.__dynamoProjectDirectory = string_copy(global.__dynamoProjectDirectory, 1, _i);
            __DynamoTrace("Project directory = \"", global.__dynamoProjectDirectory, "\"");
        }
    }
}
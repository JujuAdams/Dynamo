/// Returns the path to the project directory if Dynamo is operating in developer mode
/// If DYNAMO_DEV_MODE is set to <false> or the game is *not* being run from the IDE this function will return <undefined>

function DynamoDevProjectDirectory()
{
    if (__DYNAMO_DEV_MODE)
    {
        if (global.__dynamoProjectDirectory == undefined)
        {
            if (!file_exists(working_directory + __DYNAMO_PROJECT_DIRECTORY_PATH_NAME))
            {
                __DynamoError("Could not find path to project directory\nPlease ensure Dynamo has been set up by running dynamo.exe in the project's root directory");
                return;
            }
            else
            {
                try
                {
                    var _buffer = buffer_load(working_directory + __DYNAMO_PROJECT_DIRECTORY_PATH_NAME);
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
        
        return global.__dynamoProjectDirectory;
    }
    
    return undefined;
}
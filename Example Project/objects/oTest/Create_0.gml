//Cache the contents of ExampleSimpleNote
//DynamoNoteString() and DynamoNoteBuffer() do *not* internally cache values
//Both functions will load the file so you call them as little as possible
simpleNoteContent = DynamoNoteString("ExampleSimpleNote");

//Function to update the soundSettings JSON
funcImportSoundSettings = function(_string)
{
    try
    {
        var _json = json_parse(_string);
        
        //Honestly using JSON for this is a bit unweildy due to its fussy specification
        //YAML is probably a better choice, or some other custom format that's more relaxed
        //You may want to use something from Juju's SNAP library: https://github.com/JujuAdams/SNAP
        
        soundSettings = _json;
        show_debug_message("Loaded new sound settings as \"" + json_stringify(soundSettings) + "\"");
    }
    catch(_error)
    {
        show_debug_message(_error);
    }
}

//Start with a blank settings struct, then fill it from ExampleSoundSettings
soundSettings = {};
funcImportSoundSettings(DynamoNoteString("ExampleSoundSettings"));

//Function to read some text from ..\datafilesDynamo\
funcImportExternalTextFile = function()
{
    externalTextFileContent = "<empty>";
    
    try
    {
        var _buffer = buffer_load("external text file.txt");
        externalTextFileContent = buffer_read(_buffer, buffer_text);
        buffer_delete(_buffer);
    }
    catch(_error)
    {
        show_debug_message(_error);
    }
}

funcImportExternalTextFile();

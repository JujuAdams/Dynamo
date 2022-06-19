//Set up Included Files watching
DynamoFileWatch("Root.txt", "string", function(_content)
{
    rootText = _content;
});

DynamoFileWatch("Folder\\Nested.txt", "string", function(_content)
{
    nestedText = _content;
});

DynamoFileWatch("JSON.json", "json", function(_content)
{
    jsonData = _content;
});

DynamoFileWatch("CSV.csv", "csv", function(_content)
{
    csvData = _content;
});

//Set up Notes access
DynamoNoteWatch("EmptyNote", "string", function(_content)
{
    show_message(_content);
});

DynamoNoteWatch("TestNote", "string", function(_content)
{
    show_message(_content);
});

//Set up script watching
DynamoScriptWatch(TestScript);
DynamoScriptWatch(TestScript2);

//Setting up file/note watchers doesn't automatically load anything so let's do that now
//(Scripts are, by their very nature, automatically executed by GameMaker on boot)
DynamoFileLoad("Root.txt");
DynamoFileLoad("Folder\\Nested.txt");
DynamoFileLoad("JSON.json");
DynamoFileLoad("CSV.csv");
DynamoNoteLoad("EmptyNote");
DynamoNoteLoad("TestNote");
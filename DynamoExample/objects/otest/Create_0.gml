//Set up script watching
DynamoScriptWatch(TestScript);
DynamoScriptWatch(TestScript2);

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

//Setting up file watchers doesn't automatically load files so let's do that now
//(Scripts are, by their very nature, automatically executed by GameMaker on boot)
DynamoFileLoad("Root.txt");
DynamoFileLoad("Folder\\Nested.txt");
DynamoFileLoad("JSON.json");
DynamoFileLoad("CSV.csv");
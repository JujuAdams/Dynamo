//Set up Included Files watching
DynamoFile("Root.txt", "string", true, function(_content, _callbackData)
{
    rootText = _content;
});

DynamoFile("Folder\\Nested.txt", "string", true, function(_content, _callbackData)
{
    nestedText = _content;
});

DynamoFile("JSON.json", "json", true, function(_content, _callbackData)
{
    jsonData = _content;
});

DynamoFile("CSV.csv", "csv", true, function(_content, _callbackData)
{
    csvData = _content;
});

//Set up script watching
DynamoScript(TestScript, true);
DynamoScript(TestScript2, true);

//Setting up file/note watchers doesn't automatically load anything so let's do that now
//(Scripts are, by their very nature, automatically executed by GameMaker on boot)
DynamoFileLoad("Root.txt");
DynamoFileLoad("Folder\\Nested.txt");
DynamoFileLoad("JSON.json");
DynamoFileLoad("CSV.csv");
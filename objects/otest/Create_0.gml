//Set up Included Files watching
DynamoFile("Root.txt", "string", function(_content)
{
    rootText = _content;
});

DynamoFile("Folder\\Nested.txt", "string", function(_content)
{
    nestedText = _content;
});

DynamoFile("JSON.json", "json", function(_content)
{
    jsonData = _content;
});

DynamoFile("CSV.csv", "csv", function(_content)
{
    csvData = _content;
});

//Set up script watching
DynamoScript(TestScript);
DynamoScript(TestScript2);

//Setting up file/note watchers doesn't automatically load anything so let's do that now
//(Scripts are, by their very nature, automatically executed by GameMaker on boot)
DynamoFileLoad("Root.txt");
DynamoFileLoad("Folder\\Nested.txt");
DynamoFileLoad("JSON.json");
DynamoFileLoad("CSV.csv");
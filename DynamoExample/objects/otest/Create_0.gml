DynamoWatchScript(TestScript);
DynamoWatchScript(TestScript2);

DynamoWatchFile("All.txt", "string", function(_content)
{
    allText = _content;
});

DynamoWatchFile("Folder\\Nested.txt", "string", function(_content)
{
    nestedText = _content;
});

DynamoWatchFile("Windows.txt", "string", function(_content)
{
    windowsText = _content ?? "Not exported for this platform";
});

DynamoWatchFile("macOS.txt", "string", function(_content)
{
    macText = _content ?? "Not exported for this platform";
});

DynamoFileForceLoad("All.txt");
DynamoFileForceLoad("Folder\\Nested.txt");
DynamoFileForceLoad("Windows.txt");
DynamoFileForceLoad("macOS.txt");
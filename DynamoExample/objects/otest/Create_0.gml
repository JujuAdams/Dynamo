DynamoScriptWatch(TestScript);
DynamoScriptWatch(TestScript2);

DynamoFileWatch("All.txt", "string", function(_content)
{
    allText = _content;
});

DynamoFileWatch("Folder\\Nested.txt", "string", function(_content)
{
    nestedText = _content;
});

DynamoFileWatch("Windows.txt", "string", function(_content)
{
    windowsText = _content ?? "Not exported for this platform";
});

DynamoFileWatch("macOS.txt", "string", function(_content)
{
    macText = _content ?? "Not exported for this platform";
});

DynamoFileForceLoad("All.txt");
DynamoFileForceLoad("Folder\\Nested.txt");
DynamoFileForceLoad("Windows.txt");
DynamoFileForceLoad("macOS.txt");
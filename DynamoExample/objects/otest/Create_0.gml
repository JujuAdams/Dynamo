//Set up script watching
DynamoScriptWatch(TestScript);
DynamoScriptWatch(TestScript2);

//Set up Included Files watching
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

//Setting up file watchers doesn't automatically load files so let's do that now
//(Scripts are, by their very nature, automatically executed by GameMaker on boot)
DynamoFileLoad("All.txt");
DynamoFileLoad("Folder\\Nested.txt");
DynamoFileLoad("Windows.txt");
DynamoFileLoad("macOS.txt");
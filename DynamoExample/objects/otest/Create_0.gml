//Initialize our variables
allText     = DynamoFileLoadString("All.txt");
nestedText  = DynamoFileLoadString("Folder\\Nested.txt");
windowsText = (os_type != os_windows)? "Not exported for this platform" : DynamoFileLoadString("Windows.txt");
macText     = (os_type != os_macosx )? "Not exported for this platform" : DynamoFileLoadString("Folder/Nested.txt");

//Set up script auto-loading with a callback
DynamoScriptAutoSet(true, true, function(_changesArray)
{
    show_debug_message("The following scripts have changed: " + string(_changesArray));
});

//Set up script auto-loading with a callback
DynamoSoundAutoSet(true, function(_changesArray)
{
    show_debug_message("The following sounds have changed: " + string(_changesArray));
});

//Set up file auto-loading with a callback
DynamoFileAutoSet(true, function(_changesArray)
{
    show_debug_message("The following included files have changed: " + string(_changesArray));
    
    allText    = DynamoFileLoadString("All.txt");
    nestedText = DynamoFileLoadString("Folder\\Nested.txt");
    if (os_type == os_windows) windowsText = DynamoFileLoadString("Windows.txt");
    if (os_type == os_macosx ) macText     = DynamoFileLoadString("macOS.txt");
});
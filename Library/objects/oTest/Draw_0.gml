var _string = "";
_string += "Dynamo " + __DYNAMO_VERSION + " (" + __DYNAMO_DATE + ") by @jujuadams\n";
_string += "Press F5 to force a refresh (though data will refresh when the game regains focus)\n";
_string += "\n";
_string += "\n";
_string += "Press 1 to play sndOw\n";
_string += "Press 2 to play sndPing\n";
_string += "(Edit ExampleSoundSettings to change audio parameters)\n";
_string += "\n";
_string += "\n";
_string += "Contents of ExampleSimpleNote are \"" + simpleNoteContent + "\"\n";
_string += "Notice how GM appends a newline to Note assets. Kinda weird!\n";

draw_text(10, 10, _string);

var _string = "";
_string += "Dynamo " + __DYNAMO_VERSION + " " + __DYNAMO_DATE + " by @jujuadams\n";
_string += "\n";
_string += "global.testData = " + string(global.testData) + "\n";
_string += "global.anotherVariable = " + string(global.anotherVariable) + "\n";
_string += "global.structArrayThing = " + string(global.structArrayThing) + "\n";
_string += "global.separateScript = " + string(global.separateScript) + "\n";
_string += "\n";
_string += "allText = \"" + allText + "\"\n";
_string += "nestedText = \"" + nestedText + "\"\n";
_string += "windowsText = \"" + windowsText + "\"\n";
_string += "macText = \"" + macText + "\"\n";
_string += "\n";
_string += "Press M to play a sound. sndTest volume = " + string(audio_sound_get_gain(sndTest));

draw_text(10, ((10)), _string);
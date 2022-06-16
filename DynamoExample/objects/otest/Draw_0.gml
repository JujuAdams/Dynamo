var _string = "";
_string += "Dynamo " + __DYNAMO_VERSION + " " + __DYNAMO_DATE + " by @jujuadams\n";
_string += "\n";
_string += "global.testData = " + string(global.testData) + "\n";
_string += "global.anotherVariable = " + string(global.anotherVariable) + "\n";
_string += "global.structArrayThing = " + string(global.structArrayThing) + "\n";
_string += "global.separateScript = " + string(global.separateScript) + "\n";
_string += "\n";
_string += "rootText = \"" + rootText + "\"\n";
_string += "nestedText = \"" + nestedText + "\"\n";
_string += "jsonData = " + string(jsonData) + "\n";
_string += "csvData = " + string(csvData) + "\n";

draw_text(10, 10, _string);
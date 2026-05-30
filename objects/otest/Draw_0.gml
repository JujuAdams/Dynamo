var _string = "";
_string += "Dynamo " + DYNAMO_VERSION + " " + DYNAMO_DATE + " by Juju Adams\n";
_string += "\n";
_string += "`DYNAMO_RUNNING` = " + string(DYNAMO_RUNNING) + "\n";
_string += "`DYNAMO_PROJECT_DIRECTORY` = \"" + string(DYNAMO_PROJECT_DIRECTORY) + "\"\n";
_string += "`DYNAMO_DATAFILES_DIRECTORY` = \"" + string(DYNAMO_DATAFILES_DIRECTORY) + "\"\n";
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
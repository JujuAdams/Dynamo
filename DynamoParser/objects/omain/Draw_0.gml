var _namesArray = variable_struct_get_names(global.__dynamoVariableLookup);
if (array_length(_namesArray) <= 0) return;

draw_text(10, 10, __DynamoVariable(_namesArray[0]));
draw_text(10, 30, __DynamoVariable(_namesArray[1]));
/// @param note

function DynamoNoteLoad(_note)
{
    __DynamoInitialize();
    
    if (!variable_struct_exists(global.__dynamoNoteAddedStruct, _note))
    {
        __DynamoError("\"", _note, "\" hasn't been added with DynamoNote()");
    }
    
    global.__dynamoNoteStruct[$ _note].__Load();
}
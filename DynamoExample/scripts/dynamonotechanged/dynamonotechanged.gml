/// @param note

function DynamoNoteChanged(_note)
{
    __DynamoInitialize();
    if (!__DYNAMO_DEV_MODE) return false;
    
    if (!variable_struct_exists(global.__dynamoNoteAddedStruct, _note))
    {
        __DynamoError("\"", _note, "\" hasn't been added with DynamoNoteWatch()");
    }
    
    return global.__dynamoNoteStruct[$ _note].__HasChanged();
}
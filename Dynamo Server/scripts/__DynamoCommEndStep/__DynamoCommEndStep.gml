function __DynamoCommEndStep()
{
    if (global.__dynamoCommLocal != undefined) global.__dynamoCommLocal.__EndStep();
    
    var _i = 0;
    repeat(array_length(global.__dynamoCommRemoteArray))
    {
        var _ident = global.__dynamoCommRemoteArray[_i];
        var _remote = global.__dynamoCommRemoteDictionary[$ _ident];
        
        _remote.__EndStep();
        
        if (!_remote.__alive)
        {
            variable_struct_remove(global.__dynamoCommRemoteDictionary, _ident);
            array_delete(global.__dynamoCommRemoteArray, _i, 1);
        }
        else
        {
            ++_i;
        }
    }
}
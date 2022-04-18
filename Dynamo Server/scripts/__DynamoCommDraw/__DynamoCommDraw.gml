function __DynamoCommDraw(_x, _y)
{
    if (global.__dynamoCommLocal != undefined) global.__dynamoCommLocal.__Draw(_x, _y);
        
    var _i = 0;
    repeat(array_length(global.__dynamoCommRemoteArray))
    {
        var _ident = global.__dynamoCommRemoteArray[_i];
        global.__dynamoCommRemoteDictionary[$ _ident].__Draw(_x, _y + 25 + 15*_i);
        ++_i;
    }
}
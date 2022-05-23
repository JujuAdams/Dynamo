//Make sure the existing local handler has been destroyed
if (global.__dynamoCommLocal != undefined) global.__dynamoCommLocal.__Destroy();

global.__dynamoCommLocal = new __DynamoCommLocalClass(true, global.__dynamoCommExpectedServerIdent);

if (!global.__dynamoCommLocal.__alive)
{
    global.__dynamoCommLocal = new __DynamoCommLocalClass(false);
    
    if (!global.__dynamoCommLocal.__alive)
    {
        __DynamoError("Failed to open both server and client sockets");
        instance_destroy();
        return;
    }
    
    if (!__DYNAMO_DEBUG_CLIENT)
    {
        instance_create_layer(0, 0, layer, oServerFailed);
        return;
    }
}

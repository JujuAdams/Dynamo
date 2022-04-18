global.__dynamoCommLocal = new __DynamoCommLocalClass(true);

if (!global.__dynamoCommLocal.__initializeSuccess)
{
    global.__dynamoCommLocal = new __DynamoCommLocalClass(false);
    
    if (!global.__dynamoCommLocal.__initializeSuccess)
    {
        __DynamoError("Failed to open both server and client sockets");
        instance_destroy();
        exit;
    }
    
    if (!__DYNAMO_DEBUG_CLIENT)
    {
        instance_create_layer(0, 0, layer, oServerFailed);
        exit;
    }
}

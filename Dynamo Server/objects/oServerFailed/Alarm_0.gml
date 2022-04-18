global.__dynamoCommLocal.__SendDirect("127.0.0.1", ["ServerDuplicate", global.__dynamoCommExpectedServerIdent]);
if (global.__dynamoRunningFromIDE) __DynamoError("Could not open socket for port ", global.__dynamoCommServerPort, "\nAnother instance of the server application may already be open");

alarm[1] = 1;

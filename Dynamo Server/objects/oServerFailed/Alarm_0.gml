global.__dynamoCommLocal.__Send(["ServerDuplicate", global.__dynamoCommServerIdent]);
if (global.__dynamoRunningFromIDE) __DynamoError("Could not open socket for port ", global.__dynamoCommServerPort, "\nAnother instance of the server application may already be open");
game_end();

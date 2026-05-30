# Constants

&nbsp;

`__DynamoConstants()` holds macros that you can use in your game.

&nbsp;

|Macro                       |Datatype|Purpose                                                                                                                                                                                                                                                          |
|----------------------------|--------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`DYNAMO_RUNNING`            |boolean |Whether Dynamo is able to live reload files. Always `false` if `DYNAMO_ENABLED` is set to `false`                                                                                                                                                                |
|`DYNAMO_PROJECT_DIRECTORY`  |string  |Absolute location of the game's project directory. This will be an empty string when `DYNAMO_RUNNING` is `false`                                                                                                                                                 |
|`DYNAMO_DATAFILES_DIRECTORY`|string  |Absolute location of the game's datafiles directory. This will be an empty string when `DYNAMO_RUNNING` is `false` (an empty string will point GameMaker to load from the application's installation directory so this constant can be used safely in production)|
|`DYNAMO_VERSION`            |string  |Version number for Dynamo e.g. `"5.0.0"`                                                                                                                                                                                                                         |
|`DYNAMO_DATE`               |string  |Date this version was released e.g. `"2026-05-30`                                                                                                                                                                                                                |
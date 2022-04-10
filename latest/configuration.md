# Configuration

&nbsp;

`__DynamoConfig()` holds a single macros that customises the behaviour of Dynamo. This script never needs to be directly called in code, but the script and the macro it contains must be present in a project for Dynamo to work.

?> You should edit `__DynamoConfig()` to customise iota for your own purposes.**

&nbsp;

|Macro            |Typical value|Purpose                                                                                                                                                                                                                                          |
|-----------------|-------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`DYNAMO_DEV_MODE`|`true`       |Whether to run Dyanmo is dev mode, allowing live reloading of assets. This setting only applies when running your game from the IDE. All games that have been compiled and are running from an executable will not allow live reloading of assets|                                                                                                          |
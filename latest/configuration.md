# Configuration

&nbsp;

`__DynamoConfig()` holds macros that controls the behaviour of Dynamo. This script never needs to be directly called in code, but the script and the macros it contains must be present in a project for Dynamo to work.

?> You should edit `__DynamoConfig()` to customise Dynamo for your own purposes.

&nbsp;

|Macro                         |Typical value|Purpose                                                                                                                                                                                                                                                                                            |
|------------------------------|-------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`DYNAMO_ENABLED`              |`true`       |Whether to allow Dynamo's live updating features to operate. You should set this to <false> when releasing builds                                                                                                                                                                                  |
|`DYNAMO_AUTO_SCAN`            |`true`       |Whether to automatically scan for changes to files. This is very convenient! But sometimes not what you want. If you turn this off you'll need to call `DynamoForceScan()` to rescan files for changes and then reload. You may also want to manually check for changes and handle reloads yourself|
|`DYNAMO_AUTO_PROGRESSIVE_SCAN`|`true`       |Whether to progressively scan through tracked data looking for changes when auto-scanning. The alternative is for Dynamo to only scan for changes when the window regains focus. This macro is ignored and progressive scanning is always active on MacOS due to a bug in GameMaker                |
|`DYNAMO_VERBOSE`              |`false`      |Whether to show extended debug information in the debug log. This can be useful to track down problems when using Dynamo                                                                                                                                                                           |
|`DYNAMO_CSV_TRY_REAL`         |`true`       |Values in CSV files cells are inherently strings. This macro control whether Dynamo should try to convert values in CSV files into numbers                                                                                                                                                         |
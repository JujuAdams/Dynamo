# GML Functions

&nbsp;

## `DynamoFile`

`DynamoFile(path, datatype, autoLoad, callback, [callbackData])`

**Returns:** N/A (`undefined`)

|Name            |Datatype|Purpose                                                                                                      |
|----------------|--------|-------------------------------------------------------------------------------------------------------------|
|`path`          |string  |Local path (inside `datafiles/`) of the Included File to watch                                               |
|`dataFormat`    |string  |Format that we expect this asset to use - `json` `csv` `string` or `buffer`                                  |
|`autoLoad`      |boolean |Whether to automatically load the file as soon as a change is detected by `DYNAMO_AUTO_SCAN`                 |
|`callback`      |function|Function to execute when loading an asset, either due to a forced load or because the source file has changed|
|`[callbackData]`|any     |Data to pass into the callback function (as `argument1`)                                                     |

Sets up an Included File to watch for changes. If `DYNAMO_AUTO_SCAN` is set to `true` then watched Included Files will be scanned for changes automatically. You can check if a file has changed by calling `DynamoFileChanged()` and the file can be loaded with `DynamoFileLoad()`.

If you call `DynamoFileLoad()` then the Included File will be loaded whether there have been changes or not, and the callback provided when calling `DynamoFile()` will be executed. The callback will be handed two arguments: `argument0` is the content parsed from the file (see below) and `argument1` is the callback data provided when calling `DynamoFile()`. If there're any problems whilst parsing data found in a file then `undefined` will be passed to the callback as `argument0`.

Dynamo will automatically parse the file depending on what value `dataFormat` is set to:

|Name    |Usage                                                                                  |
---------|---------------------------------------------------------------------------------------|
|`json`  |Content is parsed as JSON                                                              |
|`csv`   |Content is parsed as CSV: comma-separated, with strings delimited by double quotes     |
|`string`|Content is parsed as UTF8-formatted plaintext                                          |
|`buffer`|Content is not parsed and content is instead returned to the callback as a buffer index|

?> Much like GameMaker's native asynchronous load functionality, the buffer returned to the callback is destroyed immediately after your callback function finishes executing. If you want to keep the buffer data around then you'll need to make and keep a copy yourself.

If the `<autoLoad>` argument is set to `<true>` when calling `DynamoFile()` then the file will automatically be loaded and parsed whenever a change is detected, executing the callback as though `DynamoFileLoad()` had been called directly for the file.

Note that setting up a file watcher will not initially load a file. If you want immediate access to data inside a file at the start of your game you'll need to call `DynamoFileLoad()`.

&nbsp;

&nbsp;

## `DynamoFileLoad`

`DynamoFileLoad(path)`

**Returns:** N/A (`undefined`)

|Name  |Datatype|Purpose                                                      |
|------|--------|-------------------------------------------------------------|
|`path`|string  |Local path (inside `datafiles/`) of the Included File to load|

Forces an Included File to be loaded, executing the callback defined for the file via `DynamoFile()`.

&nbsp;

&nbsp;

## `DynamoFileChanged`

`DynamoFileChanged(path)`

**Returns:** Boolean, whether the source file has changed changed since the last time `DynamoFileChanged()` was called (targetting that Included File)

|Name  |Datatype|Purpose                                                       |
|------|--------|--------------------------------------------------------------|
|`path`|string  |Local path (inside `datafiles/`) of the Included File to check|

If your game isn't running from the IDE or `DYNAMO_ENABLED` is set to `false` this function will always return `false`.

&nbsp;

&nbsp;

## `DynamoScript`

`DynamoScript(script, autoLoad, [callback], [callbackData])`

**Returns:** N/A (`undefined`)

|Name            |Datatype|Purpose                                                                                                                                                                         |
|----------------|--------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`script`        |integer |Index of the script to watch                                                                                                                                                    |
|`autoLoad`      |boolean |Whether to automatically load and apply the script as soon as a change is detected by `DYNAMO_AUTO_SCAN`                                                                        |
|`[callback]`    |function|Optional; the function to execute when loading an asset, either due to a forced load or because the source file has changed. If no callback is provided, no callback is executed|
|`[callbackData]`|any     |Data to pass into the callback function (as `argument0`)                                                                                                                        |

Sets up a script to watch for changes. If `DYNAMO_AUTO_SCAN` is set to `true` then watched scripts will be scanned for changes automatically. You can check if a script has changed by calling `DynamoScriptChanged()`, and the script can be loaded and its changes applied with `DynamoScriptLoad()`.

Because data is being stored in a script and *not* instead a function, the code inside a script is executed on boot by the GameMaker runtime as you'd expect. This means that, unlike file watchers, data represented inside a Dynamo script is immediately available.

There are many limitations to what can be done with Dynamo and scripts. This GML parser is very stripped back and supports a small subset of GML. The parser supports:
- Setting global variables
- Creating struct / array literals (JSON)
- Most GML operators, including ternaries (`condition? valueIfTrue : valueIfFalse`)
- Executing functions
- Instantiating constructors (with `new`)

The parser does not support:
- if/else, while, etc. flow control
- Function and constructor definition
- Dot notation for variable access in structs/instances
- Square bracket notation for array value access

Tokens for macros, GML constants, assets etc. can be added by calling `DynamoScriptEnvSetToken()` and `DynamoScriptEnvSetTokenFunction()`. Please see those functions for more information.

!> All assets will be available for reference in the GML parser. As this represents a substantial security weakness, be sure to disable Dynamo for production builds by setting the configuration macro `DYNAMO_ENABLED` to `false`.

If you call `DynamoScriptLoad()` then the script will be loaded, and its changed applied, whether there have been changes or not, and the callback provided when calling `DynamoScript()` will be executed. The callback will be handed one arguments: the callback data provided when calling `DynamoScript()`.

If the `autoLoad` argument is set to `true` when calling `DynamoScript()` then the script will automatically be loaded and applied whenever a change is detected, executing the callback as though `DynamoScriptLoad()` had been called directly for the file.

Note that setting up a script watcher will not automatically execute the callback on boot. If you want to execute the callback at the start of your game you'll need to call `DynamoScriptLoad()` directly yourself.

&nbsp;

&nbsp;

## `DynamoScriptLoad`

`DynamoScriptLoad(script)`

**Returns:** N/A (`undefined`)

|Name    |Datatype|Purpose                      |
|--------|--------|-----------------------------|
|`script`|integer |Index of the script to reload|

Forces a script to be loaded, executing the callback defined for the script via `DynamoScript()` (if any).

&nbsp;

&nbsp;

## `DynamoScriptChanged`

`DynamoScriptChanged(name)`

**Returns:** Boolean, whether the source file has changed since the last time `DynamoScriptChanged()` was called (targetting that script file)

|Name  |Datatype|Purpose                     |
|------|--------|----------------------------|
|`name`|string  |Index of the script to check|

If your game isn't running from the IDE or `DYNAMO_ENABLED` is set to `false` this function will always return `false`.

&nbsp;

&nbsp;

## `DynamoScriptEnvSetToken`

*Returns:* N/A (`undefined`)

|Name       |Datatype|Purpose                   |
|-----------|--------|--------------------------|
|`tokenName`|string  |Name of the token to alias|
|`value`    |any     |Value for the token       |

Adds a token to all future script updates. When evaluated, the token will return the value set by this function. This is useful to carry across constants into the GML parser e.g. the width and height of a tile in your game.

&nbsp;

&nbsp;

## `DynamoScriptEnvSetTokenFunction`

*Returns:* N/A (`undefined`)

|Name        |Datatype|Purpose                                      |
|------------|--------|---------------------------------------------|
|`tokenName` |string  |Name of the token to alias                   |
|`function`  |function|Function to execute when evaluating the token|
|`[metadata]`|any     |Value for the token                          |

Adds a token to all future script updates. When evaluated, the token will execute the defined function. The return value from that function will be used as the value for the token. This is useful for dynamically updating values (time, mouse position and so on). The `metadata` parameter is passed as the one (and only) parameter for the defined function.

&nbsp;

&nbsp;

## `DynamoLiveUpdateEnabled`

`DynamoLiveUpdateEnabled()`

**Returns:** Boolean, whether Dynamo's live update features are enabled

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

This function will return `false` if `DYNAMO_ENABLED` is set to `false`, or the game is being run outside the GameMaker IDE.

&nbsp;

&nbsp;

## `DynamoProjectDirectory`

`DynamoProjectDirectory()`

**Returns:** String, the project directory if Dynamo is enabled, otherwise `undefined`

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

This function will return `undefined` if `DYNAMO_ENABLED` is set to `false`, or the game is being run outside the GameMaker IDE.

&nbsp;

&nbsp;

## `DynamoForceScan`

`DynamoForceScan()`

**Returns:** N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Forces Dynamo to scan all watched assets (scripts and Included Files). Any assets that have changed and are set to autoload will be reloaded. If `DYNAMO_AUTO_SCAN` is set to `true` then you don't need to call this function yourself as Dynamo will constantly scan assets for you.
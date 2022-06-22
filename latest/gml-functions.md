# GML Functions

&nbsp;

### `DynamoFile(path, datatype, callback)`

**Returns:** N/A (`undefined`)

|Name        |Datatype|Purpose                                                                                                      |
|------------|--------|-------------------------------------------------------------------------------------------------------------|
|`path`      |string  |Local path (inside `datafiles/`) of the Included File to watch                                               |
|`dataFormat`|string  |Format that we expect this asset to use - `json` `csv` `string` or `buffer`                                  |
|`callback`  |function|Function to execute when loading an asset, either due to a forced load or because the source file has changed|

Sets up an Included File to watch for changes. If `DYNAMO_AUTO_SCAN` is set to `true` then watched Included Files will be scanned for changes automatically. If a file *has* changed then it will be loaded and parsed. The parsed data will be passed into the callback function defined when calling `DynamoFile()`.

If you call `DynamoFileLoad()` then the Included File will be loaded whether there have been changes or not, and the callback will be executed as normal.

Note that setting up a file watcher will not initially load a file. If you want immediate access to data inside a file at the start of your game you'll need to call `DynamoFileLoad()`.

If there're any problems whilst parsing data found in a file then `undefined` will be passed to the callback.

`dataFormat` can be one of these strings:

|Name    |Usage                                                                                  |
---------|---------------------------------------------------------------------------------------|
|`json`  |Content is parsed as JSON                                                              |
|`csv`   |Content is parsed as CSV: comma-separated, with strings delimited by double quotes     |
|`string`|Content is parsed as UTF8-formatted plaintext                                          |
|`buffer`|Content is not parsed and content is instead returned to the callback as a buffer index|

?> Much like GameMaker's native asynchronous load functionality, the buffer returned to the callback is destroyed immediately after your callback function finishes executing. If you want to keep the buffer data around then you'll need to make and keep a copy yourself.

&nbsp;

&nbsp;

### `DynamoFileLoad(path)`

**Returns:** N/A (`undefined`)

|Name  |Datatype|Purpose                                                      |
|------|--------|-------------------------------------------------------------|
|`path`|string  |Local path (inside `datafiles/`) of the Included File to load|

This function executes the callback defined for the Note by `DynamoFile()`.

&nbsp;

&nbsp;

### `DynamoFileChanged(path)`

**Returns:** Boolean, whether the source file has changed

|Name  |Datatype|Purpose                                                       |
|------|--------|--------------------------------------------------------------|
|`path`|string  |Local path (inside `datafiles/`) of the Included File to check|

This function always returns `false` when not running the game from inside the IDE.

&nbsp;

&nbsp;

### `DynamoNote(name, datatype, callback)`

**Returns:** N/A (`undefined`)

|Name        |Datatype|Purpose                                                                                                      |
|----------|----------|-------------------------------------------------------------------------------------------------------------|
|`name`      |string  |Name of the Note asset (in your GameMaker IDE) to watch                                                      |
|`dataFormat`|string  |Format that we expect this asset to use - `json` `csv` `string` or `buffer`                                  |
|`callback`  |function|Function to execute when loading an asset, either due to a forced load or because the source file has changed|

Sets up a note file to watch for changes. If `DYNAMO_AUTO_SCAN` is set to `true` then watched Notes will be scanned for changes automatically. If a note files *has* changed then it will be loaded and parsed. The parsed data will be passed into the callback function defined when calling `DynamoNote()`.

If you call `DynamoNoteLoad()` then the Note will be loaded whether there have been changes or not, and the callback will be executed as normal.

Note that setting up a note watcher will not initially load a note. If you want immediate access to data inside a file at the start of your game you'll need to call `DynamoNoteLoad()`.

If there're any problems whilst parsing data found in a file then `undefined` will be passed to the callback.

Note files are all included automatically when compiling your game. If you'd like to exclude a note file from your compiled game then add the tag `dynamo ignore` to that note asset.

`dataFormat` can be one of these strings:

|Name    |Usage                                                                                  |
---------|---------------------------------------------------------------------------------------|
|`json`  |Content is parsed as JSON                                                              |
|`csv`   |Content is parsed as CSV: comma-separated, with strings delimited by double quotes     |
|`string`|Content is parsed as UTF8-formatted plaintext                                          |
|`buffer`|Content is not parsed and content is instead returned to the callback as a buffer index|

?> Unlike GameMaker's native asynchronous load functionality, the buffer returned to the callback is *NOT* destroyed immediately after your callback function finishes executing.

&nbsp;

&nbsp;

### `DynamoNoteLoad(name)`

**Returns:** N/A (`undefined`)

|Name  |Datatype|Purpose                                               |
|------|--------|------------------------------------------------------|
|`name`|string  |Name of the Note asset (in your GameMaker IDE) to load|

This function executes the callback defined for the Note by `DynamoNote()`.

&nbsp;

&nbsp;

### `DynamoNoteChanged(name)`

**Returns:** Boolean, whether the source file has changed

|Name  |Datatype|Purpose                                                |
|------|--------|-------------------------------------------------------|
|`name`|string  |Name of the Note asset (in your GameMaker IDE) to check|

This function always returns `false` when not running the game from inside the IDE.

&nbsp;

&nbsp;

### `DynamoScript(script, [callback])`

**Returns:** N/A (`undefined`)

|Name        |Datatype|Purpose                                                                                                                                                                         |
|------------|--------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`script`    |integer |Index of the script to watch                                                                                                                                                    |
|`[callback]`|function|Optional; the function to execute when loading an asset, either due to a forced load or because the source file has changed. If no callback is provided, no callback is executed|

Sets up a script to watch for changes. If `DYNAMO_AUTO_SCAN` is set to `true` then watched scripts will be scanned for changes automatically. If a script *has* changed then it will be loaded, parsed, and applied. If you specified a callback function when calling `DynamoScript()` then that will be executed after data in the script is applied.

Because data is being stored in a script and *not* instead a function, the code inside a script is executed on boot by the GameMaker runtime as you'd expect. This means that, unlike file watchers, data represented inside a Dynamo script is immediately available.

There are many limitations to what can be done with Dynamo and scripts. It's best to think about Dynamo scripts as being as complex as JSON but no further. It is possible to reference basic numbers and strings (of course!) as well as being able to nest arrays and structs as you would in JSON. You may also reference asset names and GameMaker constants. You cannot, however, create functions inside Dynamo scripts. You can't use conditional branching or loopsor anything that controls program "flow". Dynamo is also expecting all variables you're defining in the script to be globals.

If you call `DynamoScriptLoad()` then the script will be loaded and applied whether there have been changes or not, and the callback will be executed as normal (if defined).

&nbsp;

&nbsp;

### `DynamoScriptLoad(script)`

**Returns:** N/A (`undefined`)

|Name    |Datatype|Purpose                      |
|--------|--------|-----------------------------|
|`script`|integer |Index of the script to reload|

This function executes the callback defined for the script by `DynamoScript()`, if one has been defined.

&nbsp;

&nbsp;

### `DynamoScriptChanged(name)`

**Returns:** Boolean, whether the source file has changed

|Name  |Datatype|Purpose                     |
|------|--------|----------------------------|
|`name`|string  |Index of the script to check|

This function always returns `false` when not running the game from inside the IDE.

&nbsp;

&nbsp;

### `DynamoLiveUpdateEnabled()`

**Returns:** Boolean, whether Dynamo's live update features are enabled

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

This function will return `false` if `DYNAMO_ENABLED` is set to `false`, or the game is being run outside the GameMaker IDE.

&nbsp;

&nbsp;

### `DynamoProjectDirectory()`

**Returns:** String, the project directory if Dynamo is enabled, otherwise `undefined`

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

This function will return `undefined` if `DYNAMO_ENABLED` is set to `false`, or the game is being run outside the GameMaker IDE.

&nbsp;

&nbsp;

### `DynamoForceScan()`

**Returns:** N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Immediately checks all source files (Included Files, Notes, and scripts) for changes, and applies those changes when found.

This function does nothing when `DYNAMO_ENABLED` is set to `false`, or if the game is not running from the IDE.

&nbsp;

&nbsp;

### `DynamoGetChangedAssets()`

**Returns:** Struct containing three arrays, each of which contains which assets have changed

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Provided so that you can check for changes and apply them manually yourself. This function is not needed when using the [auto-scan](configuration) feature.

This function returns a struct with empty arrays when `DYNAMO_ENABLED` is set to `false`, or if the game is not running from the IDE.
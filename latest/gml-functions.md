# GML Functions

&nbsp;

### `DynamoNoteBuffer(name)`

**Returns:** Buffer index for the named Note asset, or `undefined` if there was a problem loading content for the asset

|Name  |Datatype|Purpose                                               |
|------|--------|------------------------------------------------------|
|`name`|string  |Name of the Note asset (in your GameMaker IDE) to read|

!> Dynamo does not store file contents for quick access. This function uses `buffer_load()` to load a file. You should cache file contents if you need fast access.

&nbsp;

&nbsp;

### `DynamoNoteString(name, [default])`

**Returns:** String that contains the plaintext contents of the entire named Note asset, or a default value if there was a problem loading content for the asset

|Name       |Datatype|Purpose                                                                                   |
|-----------|--------|------------------------------------------------------------------------------------------|
|`name`     |string  |Name of the Note asset (in your GameMaker IDE) to read                                    |
|`[default]`|any     |Value to return if there was a problem reading the Note asset. Defaults to an empty string|

!> Dynamo does not store file contents for quick access. This function uses `buffer_load()` to load a file. You should cache file contents if you need fast access.

&nbsp;

&nbsp;

### `DynamoDevCheckForChanges()`

**Returns:** An array of strings that contains the name of assets that have changed, or `undefined` if no changes were found

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

?> Can only be used in "dev mode" - when your game is being run from the IDE and when [`DYNAMO_DEV_MODE`](configuration) is set to `true`.

!> This function is slow and should only be called when absolutely necessary.

&nbsp;

&nbsp;

### `DynamoDevCheckForChangesOnRefocus()`

**Returns:** An array of strings that contains the name of assets that have changed, or `undefined` if no changes were found

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

?> Can only be used in "dev mode" - when your game is being run from the IDE and when [`DYNAMO_DEV_MODE`](configuration) is set to `true`.

!> This function needs to be called every frame and should be placed in the Step event of a controller instance.

&nbsp;

&nbsp;

### `DynamoDevSaveBuffer()`

**Returns:** N/A (`undefined`)

|Name    |Datatype|Purpose                                                                                       |
|--------|--------|----------------------------------------------------------------------------------------------|
|`buffer`|integer |Index of the buffer to save                                                                   |
|`path`  |string  |Path of the file location to save to, relative to `datafilesDynamo\` in your project directory|

?> Can only be used in "dev mode" - when your game is being run from the IDE and when [`DYNAMO_DEV_MODE`](configuration) is set to `true`.

&nbsp;

&nbsp;

### `DynamoDevSaveNoteString()`

**Returns:** N/A (`undefined`)

|Name    |Datatype|Purpose                                                                                       |
|--------|--------|----------------------------------------------------------------------------------------------|
|`string`|string  |String to save to the file                                                                    |
|`path`  |string  |Path of the file location to save to, relative to `datafilesDynamo\` in your project directory|

?> Can only be used in "dev mode" - when your game is being run from the IDE and when [`DYNAMO_DEV_MODE`](configuration) is set to `true`.

&nbsp;

&nbsp;

### `DynamoDevSaveNoteBuffer()`

**Returns:** N/A (`undefined`)

|Name       |Datatype|Purpose                                       |
|-----------|--------|----------------------------------------------|
|`buffer`   |integer |Index of the buffer to save                   |
|`noteAsset`|string  |Name of the pre-existing Note asset to save to|

If the Note asset provided does not exist then this function will fail.

?> Can only be used in "dev mode" - when your game is being run from the IDE and when [`DYNAMO_DEV_MODE`](configuration) is set to `true`.

&nbsp;

&nbsp;

### `DynamoDevSaveNoteString()`

**Returns:** N/A (`undefined`)

|Name       |Datatype|Purpose                                       |
|-----------|--------|----------------------------------------------|
|`string`   |string  |String to save to the file                    |
|`noteAsset`|string  |Name of the pre-existing Note asset to save to|

If the Note asset provided does not exist then this function will fail.

?> Can only be used in "dev mode" - when your game is being run from the IDE and when [`DYNAMO_DEV_MODE`](configuration) is set to `true`.

&nbsp;

&nbsp;

### `DynamoDevProjectDirectory()`

**Returns:** String, the path to the project directory

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

?> Can only be used in "dev mode" - when your game is being run from the IDE and when [`DYNAMO_DEV_MODE`](configuration) is set to `true`.
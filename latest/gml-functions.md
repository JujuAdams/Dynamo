# GML Functions

&nbsp;

### `DynamoNoteBuffer(name)`

**Returns:** Buffer index for the named Note asset, or `undefined` if there was a problem loading content for the asset

|Name  |Datatype|Purpose                                               |
|------|--------|------------------------------------------------------|
|`name`|string  |Name of the Note asset (in your GameMaker IDE) to read|

&nbsp;

&nbsp;

### `DynamoNoteString(name, [default])`

**Returns:** String that contains the plaintext contents of the entire named Note asset, or a default value if there was a problem loading content for the asset

|Name       |Datatype|Purpose                                                                                   |
|-----------|--------|------------------------------------------------------------------------------------------|
|`name`     |string  |Name of the Note asset (in your GameMaker IDE) to read                                    |
|`[default]`|any     |Value to return if there was a problem reading the Note asset. Defaults to an empty string|

&nbsp;

&nbsp;

### `DynamoDevCheckForChanges()`

**Returns:** An array of strings that contains the name of assets that have changed, or `undefined` if no changes were found

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

!> This function is slow and should only be called when absolutely necessary.

&nbsp;

&nbsp;

### `DynamoDevCheckForChangesOnRefocus()`

**Returns:** An array of strings that contains the name of assets that have changed, or `undefined` if no changes were found

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

!> This function needs to be called every frame and should be placed in the Step event of a controller instance.
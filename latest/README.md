<h1 align="center">Dynamo</h1>
<p align="center">Dynamic data loader for GameMaker 2022 by <b>@jujuadams</b></p>
<p align="center"><a href="https://github.com/JujuAdams/Dynamo/releases/">Download the .yymps</a></p>
<p align="center">Chat about dynamo on the <a href="https://discord.gg/8krYCqr">Discord server</a></p>

&nbsp;

## Features

Dynamo addresses three shortcomings of GameMaker's native datafiles implementation:

1. Datafiles ("Included Files") that are open in another editor often prevent GameMaker from compiling. This is especially irritating when working with CSV files. Dynamo has its own folder for datafiles (`datafilesDynamo\`) and will store your datafiles with the project no matter which other program those files are open in.
2. Datafiles cannot be updated once GameMaker has started running your game. Dynamo allows for automatic update of the datafiles available to your game whilst it's running. This is achieved with a single function call - [`DynamoDevCheckForChanges()`](gml-functions?id=dynamodevcheckforchanges) - or Dynamo can also be set up to automatically check for updates whenever the game regains focus (call [`DynamoDevCheckForChangesOnRefocus()`](gml-functions?id=dynamodevcheckforchangesonrefocus) in a Step event).
3. GameMaker doesn't allow access to Note assets in your game, instead requiring that simple text files are edited using a totally separate program. Dynamo automatically packages Note assets with your game and they can be easily accessed at runtime with either [`DynamoNoteString()`](gml-functions?id=dynamonotestringname-default) or [`DynamoNoteBuffer()`](gml-functions?id=dynamonotebuffername). Dynamo will ignore any Notes that have the `dynamo ignore` tag assigned to them.
4. Saving data back from the game into your project directory is hard work. Dynamo offers several functions to assist with this, chiefly [`DynamoDevSaveBuffer()`](gml-functions?id=dynamodevsavebufferbuffer-path) and [`DynamoDevSaveNoteString()`](gml-functions?id=dynamodevsavenotestringstring-noteasset).

## Suggestions For Use

- Note assets can store any plaintext data, such as JSON or YAML, and so can be decoded by your game easily
- Dynamo benefits data-driven games in particular (strategy titles or sims) but is also useful for adjusting simple properties in any sort of game
- Scripting for RPG quests
- Cutscene or dialogue editing
- UI layout fine adjustment
- Audio mixing

## About & Support

Dynamo allows reading of Note assets and datafiles on all GameMaker export modules, including consoles, mobile, and Opera GX. Dynamo only supports live reloading of assets when running the IDE and game on Windows. If you'd like to report a bug or suggest a feature, please use the repo's [Issues page](https://github.com/JujuAdams/Dynamo/issues). Dynamo is constantly being maintained and upgraded; bugs are usually addressed within a few days of being reported.

Dynamo is built and maintained by [@jujuadams](https://twitter.com/jujuadams), whose career is marked by a [strange and insatiable appetite for data](https://www.youtube.com/watch?v=Uj7nr6vSRvs). Juju's worked on several [commercial GameMaker games](http://www.jujuadams.com/).

This library will never truly be finished because contributions and suggestions from new users are always welcome. Dynamo wouldn't be the same without [your](https://tenor.com/search/whos-awesome-gifs) input! Make a suggestion on the repo's [Issues page](https://github.com/JujuAdams/dynamo/issues) if you'd like a feature to be added.

## License

Dynamo is licensed under the [MIT License](https://github.com/JujuAdams/dynamo/blob/master/LICENSE).

<img src="https://raw.githubusercontent.com/JujuAdams/Dynamo/master/LOGO.png" width="50%" style="display: block; margin: auto;" />
<h1 align="center">Dynamo 2.0</h1>
<p align="center">Dynamic data loader for GameMaker 2022 by <b>@jujuadams</b></p>
<p align="center"><a href="https://github.com/JujuAdams/Dynamo/releases/">Download the .yymps</a></p>
<p align="center">Chat about dynamo on the <a href="https://discord.gg/8krYCqr">Discord server</a></p>

&nbsp;

## Features

Dynamo addresses three shortcomings of GameMaker's native datafiles implementation:

1. Included Files (and data in general) cannot be updated once GameMaker has started running your game. Once you compile your game, whatever data you had is the only data GameMaker can natively access. Dynamo breaks apart this limitation and allows for automatic update of Included Files and makes the new files available to your game whilst it's running
2. GameMaker doesn't allow access to Note assets in your game, instead requiring that simple text files are edited using a totally separate program. Dynamo automatically packages Note assets with your game and they can be easily accessed at runtime with [`DynamoNoteLoad()`](gml-functions?id=dynamonoteloadname). Dynamo will ignore any Notes that have the `dynamo ignore` tag assigned to them.
3. Dynamo allows you to set up simple data definition scripts (typically JSON) to be live updated at runtime. Add the `dynamo` tag to a script to indicate that Dynamo should check for changes in the source file and then update your game

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

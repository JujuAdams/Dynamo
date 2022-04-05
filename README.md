<h1 align="center">Dynamo 0.0.3</h1>

<p align="center">Dynamic data loader for GameMaker 2022 by <b>@jujuadams</b></p>

<p align="center"><a href="https://github.com/JujuAdams/Dynamo/releases/">Download the .yymps</a></p>

<p align="center">Chat about Dynamo on the <a href="https://discord.gg/8krYCqr">Discord server</a></p>

&nbsp;

&nbsp;

- ### [Download the .yymps](https://github.com/JujuAdams/Dynamo/releases/) (setup instructions included)
- ### Talk about Dynamo on the [Discord server](https://discord.gg/8krYCqr)

&nbsp;

&nbsp;

## Features

- Automatic setup utility to plug Dynamo into the `pre_build_step.bat` and `pre_run_step.bat` batch files (creating them if needed, inserting commands into existing files otherwise)
- Files in Dynamo's own datafiles folder `datafilesDynamo\` are packaged with your game even if those files are open in another program. **This means you can have a CSV file open and run the game from IDE and GameMaker won't fail to compile!**
- Note assets in your project directory can be accessed in-game. Note assets can be edited in your project file during gameplay and live reloaded (either using `DynamoDevCheckForChanges()` or `DynamoDevCheckForChangesOnRefocus()`)
- Note assets can be exempted from Dynamo by adding `dynamo ignore` as a tag for that Note asset
- Only supported for the Windows IDE and using the Windows target platform

&nbsp;

&nbsp;

## Suggestions For Use

- Note assets can store any plaintext data, such as JSON or YAML, and so can be decoded by your game easily
- Dynamo benefits any data-driven game, such as strategy titles or sims, but can also be useful for adjusting simple properties in any sort of game
- Scripting for RPG quests
- Cutscene or dialogue editing
- UI layout fine adjustment
- Audio mixing

&nbsp;

&nbsp;

## Planned Features

- MacOS and Linux IDE support
- Live reloading of all assets in `datafilesDynamo\`
- Server broadcast system to allow live reloading on any device connected to the local network

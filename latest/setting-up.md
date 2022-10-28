# Setting Up

!> Before setting up Dynamo, please back up your project using source control. There is nothing especially complicated about what Dynamo is doing but it's better to be safe than sorry.

!> For live updating to work, you must tick the `Disable file system sandbox` option in Game Options/Windows/General. Live updating is only available on Windows at this time.

Dynamo can be installed into your project by importing the .yymps from the [GitHub releases page](https://github.com/JujuAdams/Dynamo/releases). This package contains all the scripts that you need to run Dynamo, and a special extension that allows Dynamo to process the Notes assets in your game and prepare them for use at runtime. Dynamo uses a separate program to process Notes assets and this is stored in the `/extensions/__dynamobuildscripts/` directory and is called `DynamoParser.exe`.

Now, running executables distributed by strangers you find on the internet isn't a great idea. `DynamoParser.exe` is a necessary part of Dynamo's workflow (it guarantees that the content in your game is up-to-date when you compile) so we can't get around that. However, it is easy to compile `DynamoParser.exe` for yourself so you don't have to trust my handiwork. `DynamoParser.exe` is built from the "DynamoParser" project included in the repo; if you export a .zip build and then unzip that archive into the `/extensions/__dynamobuildscripts/` folder in your project then Dynamo should work as intended.

Once you've imported Dynamo into your project, and possibly recompiled `DynamoParser.exe`, you'll want to start adding Included Files, and maybe Notes and scriptst too to Dynamo's tracker. You can do this with the `DynamoFile()`, `DynamoNote()`, and `DynamoScript()` functions. Calling one of these functions and targetting a specific asset will let Dynamo know that you want to live update that asset. These setups functions also require you to specify a callback function. This callback is executed whenever you call the associated load function for assets (e.g. `DynamoFileLoad()` for an Included File) or when Dynamo detects a change in that particular asset.

?> To ensure consistency between your production builds that you give players and your development builds, you should always use Dynamo's native `DynamoFileLoad()` function to load Included Files rather than `buffer_load()`.

Once you've got Dynamo set up to watch specific Included Files, try running the game. The first time you run Dynamo with a project you will get a failure to compile with a Dynamo-specific message in the console output. This is normal! Run the game again and Dynamo will work fine. You should be able to edit data as you wish and those changes will be reflected in the game.

You can always force a load using `DynamoFileLoad()`, `DynamoNoteLoad()`, and `DynamoScriptLoad()`. You can also force a check to see if a file has changed using the appropriate check functions too. Dynamo comes with [auto-scan]() turned on by default, but if you turn that off you can use `DynamoForceScan()` to immediately scan for, and apply, changes found in assets.

&nbsp;

### Removing Dynamo

Should you wish to remove Dynamo from your project, you'll need to take two actions:

1. Delete the Dynamo folder from the asset browser. Specifically, you'll want to make sure the `__DynamoBuildScripts` extension asset has been deleted - this is found in `Dynamo/(System)`.
2. Delete `pre_project_step.bat` or `pre_project_step.sh` from the root of your project directory. If you're using the `pre_project_step.*` build script for some other purpose then you should remove the Dynamo-specific portions of that script.
# Setting Up

!> Before setting up Dynamo, please back up your project using source control. There is nothing especially complicated about what Dynamo is doing but it's better to be safe than sorry.

!> For live updating to work, you must tick the `Disable file system sandbox` option in Game Options/Windows/General. Live updating is only available on Windows at this time.

Dynamo can be installed into your project by importing the .yymps from the [GitHub releases page](https://github.com/JujuAdams/Dynamo/releases). This package contains all the scripts that you need to run Dynamo.

Once you've imported Dynamo into your project, you'll want to start adding Included Files, and maybe scripts too, to Dynamo's tracker. You can do this with the `DynamoFile()` and `DynamoScript()` functions. Calling one of these functions and targetting a specific asset will let Dynamo know that you want to live update that asset. These setups functions also require you to specify a callback function. This callback is executed whenever you call the associated load function for assets (e.g. `DynamoFileLoad()` for an Included File) or when Dynamo detects a change in that particular asset (provided `autoLoad` is set to `true` when setting up the watcher).

?> To ensure consistency between your development and production builds, you should always use Dynamo's native `DynamoFileLoad()` function to load Included Files rather than `buffer_load()`. This may mean converting old code to use Dynamo's callbacks.

Once your watchers and callbacks are set up, you can now run your game and start seeing Dynamo in action. Whenever a change is detected, Dynamo will do three things:

1. Record that the asset has changed. You can get whether an asset has changed since the last time you checked by calling the appropriate `Dynamo*Changed()` function
2. If the asset has `autoLoad` set to `true` then the asset is loaded.
3. If the asset has been autoloaded (see above) and a callback is defined, then the callback is executed. Included Files will be parsed as per the `datafiles` argument provided when calling `DynamoFile()` and handed to the callback.

Dynamo comes with [autoscan (`DYNAMO_AUTO_SCAN`)](configuration) turned on by default, but if you turn that off you can use `DynamoForceScan()` to immediately scan for, and apply, changes found in assets. For assets that you do not want to autoload when changes are detected, you'll need to call the relevant `Dynamo*Load()` function to update data within your game.

And that's it! You can now live reload data assets in your game.

!> Don't forget: When preparing for production (public-facing) builds make sure to set [`DYNAMO_ENABLED`](configuration) to `false`. This improves the security of your game.

&nbsp;

### Updating Dynamo

From time to time I'll need to release updates to Dynamo, either to add new features or to address bugs. Updating Dynamo is really easy:

1. Delete the Dynamo folder from the asset browser
2. Reimport the Dynamo .yymps from the [GitHub releases page](https://github.com/JujuAdams/Dynamo/releases)

There may occasionally be times when more steps are needed so please read patch notes carefully.
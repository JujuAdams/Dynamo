# Setting Up

Dynamo is a little more complex than most other GameMaker libraries to set up as it requires use of compiler batch files which are awkward to set up. Fortunately Dynamo does a lot of the hard work for you!

!> Before setting up Dynamo, please back up your project using source control. There is nothing especially complicated about what Dynamo is doing but it's better to be safe than sorry.

Here're the steps:

1. Download `dynamo.exe` from the [latest release](https://github.com/JujuAdams/Dynamo/releases) and place it into your project directory
2. Run `dynamo.exe`. It will create a folder (`datafilesDynamo`), two batch files (`pre_batch_step.bat` and `pre_run_step.bat`), and a shortcut to your project's working directory (`symlinkToWorkingDirectory`). If those batch files already exist then Dynamo will insert itself into those files
3. **Make sure you keep `dynamo.exe` in the project directory!** It's needed for future Dynamo operations
4. Download the .yymps asset package from the [latest release](https://github.com/JujuAdams/Dynamo/releases) and import it into your project
5. You're now ready to use Dynamo!

Now, running executables distributed by strangers you find on the internet isn't a great idea. `dynamo.exe` is a necessary part of Dynamo's workflow (it guarantees that the content in your game is up-to-date when you compile) so we can't get around that. However, it is easy to compile `dynamo.exe` for yourself so you don't have to trust my handiwork. `dynamo.exe` is built from the "Dynamo Builder Utility" project included in this repo; if you export a .zip build and then unzip that archive into the root directory of your project then Dynamo should work as intended.

# Setting Up

1. Back up your project e.g. using source control
2. Download `dynamo.exe` from the [latest release](https://github.com/JujuAdams/Dynamo/releases) and place it into your project directory
3. Run `dynamo.exe`. It will create a folder (`datafilesDynamo`), two batch files (`pre_batch_step.bat` and `pre_run_step.bat`), and a shortcut to your project's working directory (`symlinkToWorkingDirectory`). If those batch files already exist then Dynamo will insert itself into those files
4. **Make sure you keep `dynamo.exe` in the project directory!** It's needed for future Dynamo operations
5. Download the .yymps asset package from the [latest release](https://github.com/JujuAdams/Dynamo/releases) and import it into your project
6. You're now ready to use Dynamo!

&nbsp;

?> `dynamo.exe` is built as a self-extracting .exe thanks to help from @tabularelf. This may trip up antivirus. You may want to compile `dynamo.exe` yourself to get around this problem.
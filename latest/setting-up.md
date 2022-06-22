# Setting Up

!> Before setting up Dynamo, please back up your project using source control. There is nothing especially complicated about what Dynamo is doing but it's better to be safe than sorry.

Dynamo can be installed into your project by importing the .yymps from the [GitHub releases page](https://github.com/JujuAdams/Dynamo/releases). This package contains all the scripts that you need to run Dynamo, and a special extension that allows Dynamo to process the Notes assets in your game and prepare them for use at runtime. Dynamo uses a separate program to process Notes assets and this is stored in the `/extensions/__dynamobuildscripts/` directory and is called `DynamoParser.exe`.

?> The first time you run Dynamo, you will get a failure to compile with a Dynamo-specific message in the console output. This is normal! Run the game again and Dynamo will work fine.

Now, running executables distributed by strangers you find on the internet isn't a great idea. `DynamoParser.exe` is a necessary part of Dynamo's workflow (it guarantees that the content in your game is up-to-date when you compile) so we can't get around that. However, it is easy to compile `DynamoParser.exe` for yourself so you don't have to trust my handiwork. `DynamoParser.exe` is built from the "DynamoParser" project included in the repo; if you export a .zip build and then unzip that archive into the `/extensions/__dynamobuildscripts/` folder in your project then Dynamo should work as intended.
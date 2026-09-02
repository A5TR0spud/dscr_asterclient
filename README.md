An alternative interface for [DSCR](https://dscr.dixonary.co.uk/).
Chatters run on the assumption the user has completed [TMfDS](https://store.steampowered.com/app/4080030/The_Message_from_Deep_Space/).
The UI also runs on the same assumption.

[Downloads](https://github.com/A5TR0spud/dscr_asterclient/releases/latest) &bullet; [Changelog](/CHANGELOG.md)

### Features

|Supported DSCR Features|Other Features|
|-|-|
|Basic functionality: sending, receiving, changing callsigns, truncation, etc|Complete editing of the dictionary. Additional indenting and negative spacing options. Optional color and bold/italic/etc settings. Mostly compatible with Relay3544. Safe to use with TMfDS (though TMfDS will destroy additional options).|
|Send unknown signals by "pipe escaping" (\|-#### -> @-####\_UNDEF)|Searching the dictionary by number and/or name|
|Colored callsigns and identicons|Multi-line transmission editor (shift+enter for newline) with autocomplete|
|Display of online user count|Display of currently online users' callsigns and ability to set nicknames|
|Image rendering and a link to [DSVE](https://dsve.akqqa.dev/)|More robust image parsing and no 0-folding|
|Encryption/channels (-65533, -65534, -65535, -65536)|Encryption/channels as separate tabs|
|Copying raw signals (\|-####) from any transmission (click the transmission number)|Transmission library tab lets you create, edit, save, load, and preview transmissions without sending them|

### User Manual

#### Installation

Navigate to [downloads](https://github.com/A5TR0spud/dscr_asterclient/releases/latest) and download the desired .zip for your operating system.
Unzip it, and once unzipped, run/open/execute the .exe (Windows) or .sh (Linux) to open the program.

#### Adding Dictionary

If there is no dictionary found upon opening, it will create an empty dictionary and open its file location.
Replacing the file within 60 seconds will automatically refresh in-app.
If time runs out, you can manually reload the dictionary from file by clicking the @-40\_UNDEF button near the top right;
this button will pulse as long as nothing is defined.
Pressing it will open the file location again, just in case.
The dictionary must be named "DICTIONARY-1.save", it will not recognize the file otherwise.

#### Changing Save Directory

In settings (|-241, top right), at the top of the list, press the (|-40) button.
This will open the "base" save directory.
There should be a file called "directory.txt";
open it and replace the current directory with the desired folder path.
Select the DICTIONARY-1.save file as well as all .json files (nicknames.json, library.json, and settings.json, as of 0.6.0).
Do NOT select "directory.txt".
Move the selected files into the directory specified in "directory.txt".
Close the program and re-open it.

#### Channels

|Signal|"Name"|Template|Function
|-|-|-|-|
|-65533|Leave Channel|\|-65533 \<signal or number\>|Removes a channel from display
|-65534|Join Channel|\|-65534 \<signal or number\>|Adds a channel to display in tabs. Will reopen when restarted
|-65535|Encrypt Message|\|-65535 \<signal or number\> \<message...\>|Sends the message in the corresponding channel. Typing into a channel will automatically use this key. If addressing a channel not shown, it will be visible for only this session.
|-65536|Skeleton Key|\|-65533 \|-65536 or \|-65534 \|-65536|Shows all active channels, or hides all channels not opted-into

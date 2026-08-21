An alternative interface for [DSCR](https://dscr.dixonary.co.uk/).
Chatters run on the assumption the user has completed [TMfDS](https://store.steampowered.com/app/4080030/The_Message_from_Deep_Space/).
The UI also runs on the same assumption.

[Downloads](https://github.com/A5TR0spud/dscr_asterclient/releases/latest)

### Supported DSCR Features

* Send and receive messages with a choosable callsign
* Send unknown signals by "pipe escaping" (|-#### -> @-####_UNDEF)
* Colored callsigns and identicons
* Display of online user count
* A link to DSVE
* Image rendering
* Long transmission truncation
* Encryption/channels (-65533, -65534, -65535, -65536)
* Copying raw signals (|-####) from any transmission (click the transmission number)

### DSCR Differences

* If there is no dictionary found upon opening, it will create an empty dictionary and open its file location.
You have 60 seconds to replace it for it to automatically refresh.
If time runs out, you can manually reload the dictionary from file by clicking the -40 button near the top right.
The button to manually load the dictionary will pulse as long as nothing is defined.
This will open the file location again, just in case.
The dictionary must be named "DICTIONARY-1.save", it will not recognize the file otherwise.
* Editing dictionary formatting, default formatting, notes, and names
* Searching the dictionary by number and/or name
* Creating and deleting dictionary entries
* Display of currently online users' callsigns
* Ability to nickname callsigns
* Timestamps of how long ago a message was received, in diagetic units
* Multi-line transmission editor (hold shift and press enter for a newline; enter on its own tries to send the message)
* Dictionary-chat split can be resized
* Autocomplete

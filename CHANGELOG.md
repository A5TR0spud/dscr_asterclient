# Versions

## Build 1: Some QoL

### Additions

* Dictionary now has a button to edit default formatting
* Added a save/load for preferred callsign. It gets set when manually changing callsign and gets queried every load
* Added a save/load system to be used for settings
  * Added a setting for formatting. It defaults to on.
  * Transmissions with more than 63 signals now get truncated with |-25 and an option to expand it. Setting ranges from 31 to 511.
  * Added font size setting
* Clicking the transmission number now has an option to copy raw signals. This is a temporary location while I think of a more visible place to put it that doesn't mess with formatting
* Now displays system messages for:
  * Connecting, disconnecting, reconnecting
  * Trying to send a transmission too large
  * Failure to parse a word, with the word(s) that failed

### Changes

* Parsing no longer allows indefinitely long signal names. They are capped to 20 characters, like the editor. This shouldn't affect very many people and makes parsing a LOT faster on long transmissions.
* Timestamps are now hidden unless hovering over the message (except for system messages, which always display them)
* Quartered the tolerance of auto-scroll (reduced range from 100px to 25px)
* Disabled context menus of various text boxes due to its ability to insert formatting characters
* Consecutive messages by the same user no longer have a separating dashed line
* Now handles proper closure, so phantom callsigns should be less common (still happens if connection is lost and then the client is closed before reconnecting)
* Disabled word wrapping on transmission input, as it was hijacking the cursor (manual new lines still seem buggy(?), but less so)

### Fixed Bugs

* Clicking on a message while the dictionary editor popup is open no longer eats the input and will properly close the editor


## Build 0: "Minimum Viable Product"

An alternative interface for [DSCR](https://dscr.dixonary.co.uk/)

### Supported DSCR Features

* Send and receive messages with a choosable callsign
* Send unknown signals by "pipe escaping" (|-#### -> @-####_UNDEF)
* Colored callsigns and identicons
* Display of online user count
* A link to DSVE

### Unsupported DSCR Features

Currently. I plan to implement many/all of these.
* Image rendering
* Long transmission truncation
* Saving callsigns so you don't have to re-pick it every time it opens
* Error messages for failures to parse, connect, etc
* Encryption/channels (-65533, -65534, -65535, -65536)
* Copying raw signals (|-####) from any transmission
* Audio, themes, toggles

### DSCR Differences

* If there is no dictionary found upon opening, it will create an empty dictionary and open its file location. You have 60 seconds to replace it for it to automatically refresh. If time runs out, you can manually reload the dictionary from file by clicking the -40 button near the top right. This will open the file location again, just in case. The dictionary must be named "DICTIONARY-1.save", it will not recognize the file otherwise.
* Editing dictionary formatting (except defaults), notes, and names
* Searching the dictionary by number and/or name
* Creating and deleting dictionary entries
* Display of currently online users' callsigns
* Timestamps of how long ago a message was received, in alien units
* Multi-line transmission editor (hold shift and press enter for a newline; enter on its own tries to send the message)
* Dictionary-chat split can be resized

### Extra Planned Features

* Editing default formatting
* Confirmation for deleting dictionary entries
* Settings
* Macro-Dictionary

### Known Bugs

* While typing a message, sometimes the cursor/caret will arbitrarily decide to stop behaving

### Potential Bugs

* Auto-scrolling to the most recent transmission might have some jank. It seemed to work from my limited testing but ya never know

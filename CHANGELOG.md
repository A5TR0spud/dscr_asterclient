# Versions

## --WIP--

### Changes

* Deleting dictionary entries now prompts confirmation. Courtesy of [Eearslya](https://github.com/A5TR0spud/dscr_asterclient/commits?author=Eearslya) on Discord. Hell yeah
* Added a setting to enable the following (Eearslya)
  * Signals can now be colored! (Eearslya)
  * Signals can now be underlined
* Added buttons to quickly define an unknown frequency when it's used in a transmission
* Added setting to disable "@_UNDEF" (instead using pipes (|))
* Pressing the create dictionary entry button no longer clears the input fields

### Fixes

* Reloading settings no longer deselects the current channel

* Changing

## 0.4.2

### Changes

* Swapped autocomplete for a custom implementation that doesn't betray symbols such as "-"
  * As a result, the order, quantity, and quality of results has changed
* Adjusted channel open/close and discard sound to be more distinct from the redundant sound
* Reimplemented online user sorting

### Fixes

* Fixed the join channel command playing the "redundant" sound if the channel is already shown temporarily via /key or /join skeleton_key
* Fixed being able to paste in disallowed characters to filtered line edits (dictionary edit, search signal & word)
* Fixed "break on double" true/false not refreshing

## 0.4.1

### Changes

* Autocomplete only applies when pressing TAB
* Added 3 image control inversion settings, one for each slider
* Inverted default image zoom in/out to match the slider

## Build 4: Autocomplete

### Additions

* NikZapp is now a contributor!
* Added autocomplete! Hell yeah
  * Please let us know about bugs!
* Added icon
* Settings tab now has an option to change websocket and/or attempt manual reconnect
* Added theme color setting
* Active users tab can now set nicknames
* Added a boot splash
* Added sounds for: opening, closing, sending, compilation failure, showing/hiding channel, unseen message is received, saving/cancelling dictionary changes
* Added a setting for sound volume

### Changes

* Pressing enter (but not shift+enter) will now count as pressing save in the dictionary edit popup
* Changing dictionary entries no longer resets the search
* Potentially improved signal name editing
* @ and $ are now blacklisted from signal names. This matches the game itself, so it shouldn't affect many people. I have plans for these symbols.
  * To be clear: signals with these characters in their names still work. New signals or name-changing no longer allows these characters.
  * Signals with these in the name may stop being supported in the future.
* Active users tab is more vertical
* If no dictionary or an empty dictionary is loaded, the "open/load dictionary" button will throw a rave
* Images can now be dragged to control the pitch/yaw sliders indirectly. Hovering over one and scrolling zooms.

### Fixes

* Fixed the root cause of janky multiline in the chat entry. This means automatic word wrapping is back!
* Fixed maybe-long-standing bug where sending a pipe (|) without a valid number following it causes a crash
* Can no longer type non-numbers into the number search or blacklisted characters into the name search
* Pressing the dictionary source button correctly reloads the dictionary again

## Build 3: Channels

### Additions

* Channels have been implemented primarily by [@nikzapp](https://github.com/A5TR0spud/dscr_asterclient/commits?author=NikZapp) on Discord. Hell yeah
* As a reminder:
  * Sending "|-65535 (key) (message)" will hide the message from normal chat
  * Sending "|-65534 (key)" will display messages otherwise hidden via the above method, for that specific key
  * Sending "|-65533 (key)" will stop displaying messages from that key
  * |-65536 is a special key that will show all available channels when enabled via |-65534
* Note: if a channel is selected, "|-65535 (key)" will automatically be prepended, unless the sent message starts with |-65535
* Added computer message for failure to name something identically to an existing signal

### Changes

* Identicons no longer render via shader
* Pressing enter on the signal name search/create bar now acts as though the button has been pressed

## Build 2: Visual Information

### Additions

* Images now render. Hell yeah.
  * Colors courtesy of [@elnico56 on Discord and dixonary on Github](https://github.com/dixonary/mfds-server/blob/0d359cef41a64cfe2bddbacb12898f066fa099b8/public/mfds.js#L1009-L1034)
  * Added a setting for whether new images should be visible by default

### Fixes

* Disabled context menu in dictionary editor popup
* Deleting a signal now properly saves
* Fixed the |-25 button not going away when shooed (changing max length setting)

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

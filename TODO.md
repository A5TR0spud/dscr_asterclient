## TODO

* add signal-matching options? (eg recolor matching pairs of -14 and -15, autocompleting -14 also types -15)
* add "macro-dictionary" tab
* probably add macros as an emoji keyboard type of thing rather than another parser
  * autocomplete option that fills in a combo of signals rather than itself
* figure out what to do if a transmission is not received (ie a number is skipped)
* entering signals into notes so that they auto-update
* hover over numbers to get the translation
* implement message history so you can use arrow keys to access your previous transmissions
* Image editor tab (w/ compat vs compact exports)
* Image camera control strafe/walk/fly that doesn't require a keyboard
* audio editor tab (with support for sequences and such)
* something for element names
* tagging signals and searching by tag
* word aliases (unless the macro system is sufficient)
* figure out transmission history `shown_transmissions` slipping
* ability to block channels when using the skeleton key
* music parsing for sine vs square vs saw vs triangle vs smooth square?
* autocomplete for nicknames to numbers
* fix emoji not working
* add option to hide transmissions with -132010 in them (truncate to 0 signals and new button)
* setting to get a ping sound when callsign is spoken and channel is not focused
* ctrl+f
* online indicator for callsigns in chat?
* song queue visualization
* per-channel notification sounds
* split history per websocket
* bool setting: message log txts per-day (sender, trx, wss, timestamp (unix), timestamp (system date and time), message (signals))
* separate color indicator reference setting (off, number, reference (at end of trx, in context buttons))

### nikzapp

* arbitrary parsing/clean up parser
* lua modules/plugins
* android support

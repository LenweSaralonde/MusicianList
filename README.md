MusicianList
============

Load and save songs in game for the [Musician](https://musician.lenwe.io) add-on.

The song list is accessible from Musician main menu on the minimap or by clicking the list button in the main import window.

To save the current song to the list, press the **Save** button in the main import window or in the song editor.

Highlight a song to show the action buttons (play, rename, share, delete).

Type `/mus help` to get the command list.

Special thanks to [Mystic Zaru](https://www.youtube.com/channel/UCDeGhURXdgXnCS77wh_cWDg), [Eldorias](https://www.youtube.com/channel/UC6j5rkx9SUAiHqlNYK5egAA]) and Oliira-Moonguard for the demo songs!

Command list
------------

### Open song list
`/mus list`

`/mus songs`

### Save the current song
`/mus save [<song name>]`

If omitted, the song name shown in the import field will be used.

### Load a song
`/mus load (<song name>|<song number>)`

### Load and play a song
`/mus play (<song name>|<song number>)`

### Load and preview a song
`/mus preview (<song name>|<song number>)`

### Filter song name
`/mus find <song name>`

`/mus search <song name>`

`/mus filter <song name>`

### Delete song
`/mus delete [(<song name>|<song number>)]`

`/mus del [(<song name>|<song number>)]`

`/mus remove [(<song name>|<song number>)]`

If no song name or number is specified, the currently loaded song will be deleted.

### Rename song
`/mus rename [<song number> [<new name>]]`

`/mus ren [<song number> [<new name>]]`

`/mus mv [<song number> [<new name>]]`

If no parameter is specified, the currently loaded song will be renamed.

### Restore demo songs
`/mus demosongs`

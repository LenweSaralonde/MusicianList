MusicianList
============

Add load and save features for the addon [Musician](https://lenwe.info/musician).
This addon has no UI and has to be used in command line only.

Musician commands start by `/musician` but you can also use `/music` or `/mus`.

List available songs
--------------------
`/musician list`
`/musician songs`
* Click on the song name to load it.
* Click on the play button ► to load it and play.

Save current song
-----------------
`/musician save [<song name>]`

If omitted, the song name shown in the import field will be used.

Load song
----------
`/musician load (<song name>|<song number>)`

Load and play song
------------------
`/musician play (<song name>|<song number>)`

Find a song
-----------
`/musician find <keywords>`
`/musician search <keywords>`

Delete song
-----------
`/musician delete [(<song name>|<song number>)]`
`/musician del [(<song name>|<song number>)]`
`/musician remove [(<song name>|<song number>)]`

If no song name or number is specified, the currently loaded song will be deleted.
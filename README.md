# Music2SQL

Node module for reading metadata from audio files and store it into a SQL database.

## Features
 - Load metadata from mp3, flac, mp4, ogg audio files
 - Extract embeded album covers to image files
 - Fingerprint audio files using [AcoustID](http://musicbrainz.org/doc/AcoustID) or [LastFM](https://github.com/lastfm/Fingerprinter) fingerprinter
 - Resolve generated fingerprints to [MusicBrainz Identifier](http://musicbrainz.org/doc/MusicBrainz_Identifier) (MBID)
 - Fetch artist, album or song information from lastfm and musicbrainz

## Usage

```coffeescript

coffeeScript  = require 'coffee-script'
Music2Sql     = require './lib/music2sql'

# Initialize
music = new Music2Sql
  lastFM_ApiKey: "<your key>"
  acoustID_ClientId: "<your client ID>"

# Generate database
music.setupDatabase()

# Import
importOptions =
  # path to import
  path: "/Users/Matthias/Music/"
  # Array of strings - if matched with file path file gets excluded
  excludes: ["Musik/Misc"]

music.import importOptions, (err, songs) ->
  songs.forEach (song) ->
    if song
      song.generateLastFMFingerprint (err, fingerprint) ->
        # ...
      song.generateAcoustIDFingerprint (err, fingerprint) ->
        # ...
```

## Fingerprinting dependencies
 - Chromaprint [fpcalc](http://acoustid.org/chromaprint)
 - [LastFM](https://github.com/lastfm/Fingerprinter) fingerprinter

## Contributing

* Create something, make the code better, add some functionality
* [Fork](http://help.github.com/forking/)
* Create new branch for your changes
* Commit all your changes to your branch
* Submit a [pull request](http://help.github.com/pull-requests/)

## Contact

Feel free to get in touch.

* Website: <http://matthiasleitner.com>
* Twitter: [@matthiasleitner](http://twitter.com/matthiasleitner)

### Licence


Copyright (C) 2013 Matthias Leitner

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
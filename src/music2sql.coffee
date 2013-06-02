db            = require './models/db'

Album  = db.import __dirname + '/models/album'
Artist = db.import __dirname + '/models/artist'
Import = db.import __dirname + '/models/import'
Song   = db.import __dirname + '/models/song'

LastFM        = require './providers/lastfm'
AcoustID      = require './providers/acoust_id'
MusicBrainz   = require './providers/musicbrainz'

class Music2Sql
  constructor: (@config) ->
    LastFM.setApiKey @config.lastFM_ApiKey
    AcoustID.setClientId @config.acoustID_ClientId

  clearDatabase: ->
    db.sync
      force: true

  setupDatabase: (callback) ->
    db.sync()

  import: (options, done) ->
    Import.build(options).perform(done)

  @providers:
    AcoustID: AcoustID
    LastFM: LastFM
    MusicBrainz: MusicBrainz

  @models:
    Album: Album
    Artist: Artist
    Import: Import
    Song: Song


module.exports = Music2Sql
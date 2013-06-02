db            = require './models/db'

Import        = db.import __dirname + '/models/import'

LastFM        = require './providers/lastfm'
AcoustID      = require './providers/acoust_id'

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


module.exports = Music2Sql
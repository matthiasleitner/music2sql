db           = require './db'
LastFM       = require '../providers/lastfm'
MusicBraninz = require '../providers/musicbrainz'

Album        = db.import __dirname + '/album'

module.exports = (sequelize, DataTypes) ->
  sequelize.define "artist",
    name: DataTypes.STRING
    image_url: DataTypes.STRING
    lastfm_url: DataTypes.STRING
    mbid: DataTypes.STRING
  ,
    instanceMethods:
      loadLastFMData: (done) ->
        LastFM.getArtistInfo
          artist: @name
          mbid:   @mbid
        , done

      loadMusicBrainData: (done) ->
        MusicBraninz.getArtistInfo
          mbid: @mbid
        , done

    classMethods:
      createFromMetadata: (metadata, done) ->
        artistName = @_nameFromMetadata(metadata)

        unless artistName
          done "no artist name" , null
          return

        @findOrCreate(name: artistName).success((artist, created) ->
          done null, artist
        ).error (err) ->
          done err, null


      _nameFromMetadata: (metadata) ->
        #prefer album artist
        if metadata.albumartist.length > 0
          metadata.albumartist[0]
        else if metadata.artist.length > 0
          metadata.artist[0]



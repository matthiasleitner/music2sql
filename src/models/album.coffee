db     = require './db'

module.exports = (sequelize, DataTypes) ->
  sequelize.define "album",
    artist_id: DataTypes.INTEGER
    artist_name: DataTypes.STRING
    title: DataTypes.STRING
    cover_url: DataTypes.STRING
    mbid: DataTypes.STRING
  ,
    classMethods:
      createFromMetadata: (metadata, artist, done) ->
        if metadata.album
          artistId = if artist? then artist.id else null

          @find(
            where:
              title: metadata.album
              artist_id: artistId
          ).success (album) =>
            console.log "find album"
            console.log album
            if album
              done null, album
              return

            console.log "create album #{metadata.album}"

            album = @build()
            album.title = metadata.album

            if artist
              album.artist_id = artist.id
              album.artist_name  = artist.name

            if metadata.cover_url
              album.cover_url = metadata.cover_url

            album.save().success((task) ->
              done null, album
            ).error (err) ->
              done err, null

        else
          done "no album info", null

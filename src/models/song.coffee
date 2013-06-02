fs        = require 'fs'
request   = require 'request'
db        = require './db'

LastFM    = require '../providers/lastfm'
AcoustID  = require '../providers/acoust_id'

Artist    = db.import __dirname + '/artist'
Import    = db.import __dirname + '/import'

module.exports = (sequelize, DataTypes) ->
  Song = sequelize.define "song",
    artist_id: DataTypes.INTEGER
    artist_name: DataTypes.STRING
    album_id: DataTypes.INTEGER
    album_title: DataTypes.STRING
    album_artist_name: DataTypes.STRING
    acoustid_fingerprint: DataTypes.TEXT
    comments: DataTypes.STRING
    cover_url: DataTypes.STRING
    disk_number: DataTypes.INTEGER
    disk_total: DataTypes.INTEGER
    duration: DataTypes.INTEGER
    genre: DataTypes.STRING
    import_id: DataTypes.INTEGER
    lastfm_fingerprint: DataTypes.STRING
    mbid: DataTypes.STRING
    title: DataTypes.STRING
    track_number: DataTypes.INTEGER
    track_total: DataTypes.INTEGER
    url: DataTypes.STRING
    year: DataTypes.INTEGER
  ,
    instanceMethods:

      # LASTFM
      # ------------------------------------------------------
      # Generate lastfm fingerprint for the song
      # https://github.com/lastfm/Fingerprinter
      generateLastFMFingerprint: (done) ->
        @getFullPath (fullPath) =>
          LastFM.generateFingerprint fullPath, (err, fingerprint) =>
            @lastfm_fingerprint = fingerprint
            @save().success =>
              done null, @lastfm_fingerprint

      getLastFMFingerprintInfo: (done) ->
        LastFM.getFingerprintInfo @lastfm_fingerprint,
                                  done

      # AcoustID
      # ------------------------------------------------------
      # Generate AcoustID fingerpint for the song
      # http://musicbrainz.org/doc/AcoustID
      generateAcoustIDFingerprint: (done) ->
        @getFullPath (fullPath) =>
          AcoustID.generateFingerprint fullPath, (err, data) =>
            if err
              return done "error generating fingerprint", null

            @duration = data.duration
            @acoustid_fingerprint = data.fingerprint

            @save().success ->
              done null, data

      getAcoustIDFingerprintInfo: (done) ->
        AcoustID.getFingerprintInfo @acoustid_fingerprint,
                                    @duration
                                    done

      storeCover: (metadata, done = ->) ->
        artistName = Artist._nameFromMetadata(metadata)

        picture = metadata.picture[0]

        fileName = "#{artistName}_#{metadata.album}.#{picture.format}"
        fileName = "#{__dirname}/../../covers/#{fileName}".replace(/\s/g, '')

        buffer             = picture.data

        @cover_url = fileName
        @save

        # only store cover once
        fs.exists fileName, (exists) =>
          if exists
            return done metadata

          fs.writeFile fileName, buffer, (err) =>
            done metadata

      getFullPath: (done) ->
        @getImport().success (imp) =>
          done "#{imp.path}#{@url}"


      # Check if the song has one of the given file types
      hasFileType: (file_types) ->
        for file_type in file_types
          dotType = ".#{file_type}"
          if this.url.indexOf(dotType) > 0
            return true
        false

      matchesPath: (exclude_paths) ->
        for exclude_path in exclude_paths
          if this.url.indexOf(exclude_path) > 0
            return true
        false

    classMethods:
      createFromMetadata: (metadata, artist = null, album = null, done) ->
        console.log "create song #{metadata.title}"

        song              = @build()

        song.url          = metadata.url
        song.import_id    = metadata.import_id

        song.title        = metadata.title
        song.comments     = metadata.comment
        song.year         = metadata.year

        if metadata.genre
          song.genre        = metadata.genre.join("/")

        if metadata.disk
          song.disk_number  = metadata.disk.no
          song.disk_total   = metadata.disk.of

        if metadata.track
          song.track_number = metadata.track.no
          song.track_total  = metadata.track.of

        if artist
          song.artist_id    = artist.id
          song.artist_name  = metadata.artist[0]
          song.album_artist_name = metadata.albumartist[0]

        if album
          song.album_title  = album.title
          song.album_id     = album.id

        if metadata.cover_url
          song.cover_url    = metadata.cover_url

        # save song
        song.save().success( (song) ->

          if metadata.picture.length?
            song.storeCover metadata

          done null, song
        ).error (err) ->
          done err, null

  Song.belongsTo Import
  Song.belongsTo Artist

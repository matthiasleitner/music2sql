musicmetadata = require 'musicmetadata'
fs            = require 'fs'
async         = require 'async'
db            = require './db'
FileList      = require '../utils/filelist'

module.exports = (sequelize, DataTypes) ->
  sequelize.define "import",
    path: DataTypes.STRING
  ,
    instanceMethods:
      perform: (done = ->) ->
        @save().success( =>
          @loadFileList @path, (err, fileList) =>
            async.mapSeries fileList, @processMap.bind(this), done
        )

      loadMetadata: (url, done) ->
        parser = new musicmetadata(fs.createReadStream(url))

        #listen for the metadata event
        parser.on 'metadata', done

      processURL: (url, done) ->
        Song = db.import __dirname + '/song'
        song = Song.build url: url

        # ensure existence of file
        fs.exists song.url, (exists) =>
          unless exists
            return done "file #{song.url} does not exists", null

          unless song.hasFileType ["mp3", "flac", "mp4", "ogg"]
            return done "file #{song.url} incompatible", null

          if @excludes and song.matchesPath @excludes
            return done "file #{song.url} ignored", null

          relative_url = song.url.replace @path, ''

          Song.find(
            where:
              url: relative_url
          ).success (song) =>
            if song
              return done "skipping #{url} - exists", null

            handleProperties = (properties) ->
              properties.url       = relative_url
              properties.import_id = @id
              @createFromMetadata properties, done

            @loadMetadata url, handleProperties.bind(this)


      processMap: (url, done) ->
        @processURL url, (err, res) =>
          done null, res

      createFromMetadata: (metadata, done) ->
        Artist = db.import __dirname + '/artist'
        Album  = db.import __dirname + '/album'
        Song   = db.import __dirname + '/song'

        createSong = (err, album) ->
          Song.createFromMetadata metadata, @artist, album, done

        createAlbum = (err, artist) ->
          Album.createFromMetadata metadata, artist, createSong.bind(artist: artist)

        Artist.createFromMetadata metadata, createAlbum

      loadFileList: (path, done) ->
        new FileList().load path, done


    classMethods: {}
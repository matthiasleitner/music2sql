request   = require('request')
exec      = require('child_process').exec

class Config
  constructor: (@_apiKey) ->
  get: -> @_apiKey

class LastFM
  _config = null

  @setApiKey: (apiKey) ->
    _config = new Config(apiKey)

  @getApiKey: ->
    unless _config
      throw "API key not set"
    _config.get()

  @generateFingerprint: (filePath, done) ->
    unless filePath.indexOf(".mp3")
      done "only .mp3 files supported", null
      return

    command = "lastfmfpclient \"#{filePath}\" -nometadata"

    exec command, (error, stdout, stderr) =>
      unless not error and not stderr
        done
          error:  error
          stderr: stderr
        , null

        return

      console.log "stdout: #{stdout}"

      fp = stdout.replace(/(\r\n|\n|\r)/gm,"")
                 .match(/(.*)FOUND/)[1]

      done null, fp

  @getArtistInfo: (options, done) ->
    unless options.mbid or options.name
      done "mbid or name required", null
      return

    @_request "artist.getinfo",
              options,
              done

  @getFingerprintInfo: (fingerprint, done) ->
    unless fingerprint
      done "no fingerprint given", null
      return

    options =
      fingerprintid: fingerprint.replace(/^\s+|\s+$/g, '')

    @_request "track.getfingerprintmetadata",
              options,
              done

  @_request: (method, options, done) ->

    options.method  = method
    options.api_key = @getApiKey()
    options.format  = "json"

    request
      uri: @_apiHost()
      headers:
        Accept: "application/json"
      qs:
        options
    , (error, response, body) =>
      done error, body

  @_apiHost: ->
    "http://ws.audioscrobbler.com/2.0"

module.exports = LastFM
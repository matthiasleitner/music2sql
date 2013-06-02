request   = require('request')
exec      = require('child_process').exec

class Config
  constructor: (@_clientId) ->
  get: -> @_clientId

class AcoustID
  _config = null

  @setClientId: (clientId) ->
    _config = new Config(clientId)

  @getClientId: ->
    unless _config
      throw "Client ID not set"
    _config.get()

  @generateFingerprint: (file_path, done) ->
    command = "./fpcalc  \"#{file_path}\""

    exec command, (error, stdout, stderr) =>
      if error or stderr
        done
          error:  error
          stderr: stderr
        , null
        return

      duration = stdout.replace(/(\r\n|\n|\r)/gm,"")
                       .match("DURATION=(.*)FINGERPRINT")

      # fingerprints without duration are useless
      unless duration?
        done "error generating fingerprint", null
        return

      fp = stdout.match(/FINGERPRINT=(.*)/)[1]

      done null,
        duration: duration[1]
        fingerprint: fp

  @getFingerprintInfo: (options,  done) ->
    unless options.fingerprint and options.duration
      done "fingerprint and duration required", null
      return

    request
      uri: "http://api.acoustid.org/v2/lookup?meta=recordings+releasegroups+compress"
      qs:
        client: @getClientId()
        duration: options.duration
        fingerprint: options.fingerprint
      , (error, response, body) =>
        done error, JSON.parse(body)

  @getMBIDsFromFingerprintInfo: (info) ->
    unless info?
      return null

    results = info.results
    unless results and results.length
      return null

    recordings = results[0].recordings
    unless recordings and recordings.length
      return null

    recording = recordings[0]

    mbids =
      song: recording.id

    artists = recording.artists

    if artists and artists.length
      mbids.artist = artists[0].id

    mbids

module.exports = AcoustID
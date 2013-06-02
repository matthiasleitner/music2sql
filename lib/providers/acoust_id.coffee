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

  @getFingerprintInfo: (fingerprint, duration,  done) ->
    unless fingerprint and duration
      done "fingerprint and duration required", null
      return

    request
      uri: "http://api.acoustid.org/v2/lookup"
      qs:
        client: @getClientId()
        meta: "recordings+releasegroups+compress"
        duration: duration
        fingerprint: fingerprint
      , (error, response, body) =>
        done error, body


module.exports = AcoustID
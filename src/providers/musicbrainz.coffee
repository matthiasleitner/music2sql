request = require('request')

class MusicBraninz
  @getArtistInfo: (options, done) ->
    unless options.mbid
      done "no mbid given", null
      return

    uri =  "http://musicbrainz.org/ws/2/artist/#{options.mbid}"

    properties = ["artist-rels",
                  "url-rels",
                  "recordings",
                  "releases",
                  "release",
                  "groups",
                  "works",
                  "aliases",
                  "tags",
                  "ratings",
                  "discids",
                  "isrcs",
                  "media",
                  "artist-credits"]

    request
      uri: uri
      qs:
        inc: properties.join("+")
      , (error, response, body) =>
        done error, body

module.exports = MusicBraninz

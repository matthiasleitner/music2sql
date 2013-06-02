fs = require 'fs'
class FileList
  load: (dir, done) ->
    results = []
    fs.readdir dir, (err, files) =>
      return done err if err

      pending = files.length

      unless pending
        return done null, results

      files.forEach (file) =>
        file = "#{dir}/#{file}"

        fs.stat file, (err, stat) =>
          if stat and stat.isDirectory()
            @load file, (err, res) =>
              results = results.concat(res)
              unless --pending
                done null, results
          else
            results.push file
            unless --pending
              done null, results

  persist: (list, destination, done) ->
    json = JSON.stringify list, null, 4

    fs.writeFile destination, json, (err) ->
        done err, json

module.exports = FileList
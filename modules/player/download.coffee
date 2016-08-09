youtubedl = require 'youtube-dl'
fs = require 'fs'
Chance = require 'chance'
EventEmitter = require 'events'

class VideoDownload extends EventEmitter
  constructor: (@nameOrUrl)->
    # Get a random filename
    @filename = new Chance().string {
      length: 6
      pool: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    }
    @path = './data/tmp/'+@filename

    youtubedl.getInfo @nameOrUrl, ['--default-search', 'ytsearch', '-f', 'bestaudio'], (err, @info)=>
      if err
        @emit 'error', err
      else
        @filename += '.'+@info.ext
        @path += '.'+@info.ext
        @emit 'info', @info

  download: => new Promise (resolve, reject)=>
    @dl = youtubedl @nameOrUrl,
                    ['--default-search', 'ytsearch', '-f', 'bestaudio']
    @dl.pipe fs.createWriteStream @path
    @dl.on 'end', resolve
    @dl.on 'error', reject

  deleteFiles: ()=>
    fs.unlink @path

module.exports = VideoDownload

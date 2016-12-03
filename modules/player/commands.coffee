reload = require('require-reload')(require)
youtubedl = require 'youtube-dl'
{ spawn } = require 'child_process'
moment = require 'moment'

class AudioModuleCommands
  constructor: (@audioModule)->
    { @registerCommand } = @audioModule
    { @permissions } = Core
    { @parseTime } = Core.util
    @m = @audioModule

    # Play
    @m.registerCommand 'play', { argSeparator: '|' }, (msg,args,data)=>
      return msg.reply 'No video specified.' if not args[0].trim() and not msg.attachments[0]
      return msg.reply 'You must be in a voice channel to request songs.' if not msg.member.getVoiceChannel()
      urlToFind = args[0]
      urlToFind = msg.attachments[0].url if msg.attachments[0]

      youtubedl.getInfo urlToFind, ['--default-search', 'ytsearch', '-f', 'bestaudio'], (err, info)=>
        if err
          return youtubedl.getInfo urlToFind, [], (error, info)=>
            return msg.reply 'Something went wrong.' if error
            @getLength(info).then (i)=> @audioModule.handleVideoInfo i, msg, args, data
        @getLength(info).then (i)=> @audioModule.handleVideoInfo i, msg, args, data

  # Try to get the duration from FFProbe (for direct links and other streams)
  getLength: (info)=> new Promise (resolve, reject)=>
    return resolve(info) if isFinite info.duration or typeof info.forEach is 'function'
    ffprobe = spawn('ffprobe', [info.url, '-show_format', '-v', 'quiet'])
    ffprobe.stdout.on 'data', (data)=>
      try
        # Parse the output from FFProbe
        prop = { }
        pattern = /(.*)=(.*)/g
        while match = pattern.exec data
          prop[match[1]] = match[2]
        # Get the duration
        info.duration = prop.duration
        # Try to use metadata from the ID3 tags as well
        if prop['TAG:title']
          info.title = ''
          info.title += "#{prop['TAG:artist']} - " if prop['TAG:artist']
          info.title += prop['TAG:title']
      resolve info

module.exports = AudioModuleCommands

AudioModuleCommands = require './commands'
QueueManager = require './queueManager'
AudioHud = require './hud'
audioFilters = require './filters'
{ spawn } = require 'child_process'
{ delay } = Core.util

class PlayerModule extends BotModule
  init: =>
    { @permissions } = @engine
    @hud = new AudioHud @
    @q = new QueueManager @
    @moduleCommands = new AudioModuleCommands @
    { @parseTime } = Core.util

    if Core.settings.debug and Core.commands.registered['eval']
      @registerCommand 'playereval', { ownerOnly: true }, (msg, args)=>
        queue = await @q.getForGuild msg.guild
        Core.commands.registered['eval'].func.call({ queue }, msg, args, queue.guildData, Core.bot, Core)

  handleVideoInfo: (info, msg, args, gdata, playlist=false)=>
    # Handle playlists
    if typeof info.forEach is 'function'
      return msg.reply "Only people with the DJ role (or higher) is allowed to add playlists." if not @permissions.isDJ(msg.member)
      msg.channel.sendMessage '', false, @hud.addPlaylist(msg.member, info.length)
      for v in info
        await @handleVideoInfo(v, msg, args, gdata, true)
      return

    queue = await @q.getForGuild msg.guild
    info = await @getAdditionalMetadata(info)

    # Check for video length
    duration = @parseTime info.duration
    if (duration > gdata.data.maxSongLength and not @permissions.isDJ(msg.author, msg.guild)) or
       (duration > 7200  and not @permissions.isAdmin(msg.author, msg.guild)) or
       (duration > 43200 and not @permissions.isOwner(msg.author))
        return if playlist
        return msg.reply 'The requested song is too long.'

    # Apply filters
    try
      filters = @getFilters(args[1], msg.member)
    catch errors
      if typeof errors is 'string'
        return if playlist
        return msg.reply 'A filter reported errors:', false, { description: errors, color: 0xFF0000 }

    # Add to queue
    queue.addToQueue({
      title: info.title
      requestedBy: msg.member
      voiceChannel: msg.member.getVoiceChannel()
      textChannel: msg.channel
      path: info.url
      sauce: info.webpage_url
      thumbnail: info.thumbnail
      radioStream: info.isRadioStream or false
      playlist
      duration
      filters
    })

    # Skip if there was a previous item playing prior to a bot restart
    if queue.nowPlaying and queue.nowPlaying.status is 'playing' and not queue.audioPlayer.encoderStream
      queue.nextItem()

  getAdditionalMetadata: (info)=> new Promise (resolve, reject)=>
    return resolve(info) if info.duration and isFinite(info.duration)
    d = ""
    p = spawn('ffprobe', [info.url, '-show_format', '-v', 'quiet', '-print_format', 'json'])
    p.stdout.on 'data', (data)=> d += data
    p.on 'close', (code)=>
      return reject "Process exited with code #{code}" if code
      try
        prop = JSON.parse(d).format
        # Get the duration
        info.duration = prop.duration or NaN
        # Try to use metadata from the ID3 tags as well
        if prop.tags.title
          info.title = ''
          info.title += "#{prop.tags.artist} - " if prop.tags.artist
          info.title += prop.tags.title
        # Is this an internet radio stream?
        if prop.tags.StreamTitle or prop.tags['icy-name']
          info.isRadioStream = true
          info.title = prop.tags['icy-name'] if prop.tags['icy-name']
      resolve(info)

  getFilters: (arg, member, playing)=>
    return [] if not arg
    filters = []
    for filter in arg.match(/\w+=?\S*/g)
      name = filter.split('=')[0]
      param = filter.split('=')[1]
      Filter = audioFilters[name]
      continue if not Filter
      f = new Filter(param, member, playing, filters)
      if playing and f.avoidRuntime
        throw f.display + ' is a static filter and cannot be applied during playback.'
      filters.push(f)
    filters

module.exports = PlayerModule

QueueItem = require '../../models/audioQueueItem'
moment = require 'moment'
reload = require('require-reload')(require)
AudioModuleCommands = reload './commands'
audioFilters = reload '../../filters'
AudioHud = reload './hud'

class PlayerModule extends BotModule
  init: =>
    { @permissions, @getGuildData, @webHooks } = @engine
    @audioFilters = audioFilters
    @hud = new AudioHud @
    @moduleCommands = new AudioModuleCommands @

  parseTime:(time)=>
    t = time.split(':').reverse()
    moment.duration {
      seconds: t[0]
      minutes: t[1]
      hours:   t[2]
    }
    .asSeconds()      

  handleVideoInfo: (info, msg, args, gdata, silent=false)=>
    # Check if playlist
    if typeof info.forEach is 'function'
      if not @permissions.isDJ(msg.author, msg.guild)
        return msg.reply "Only people with the DJ role (or higher) is allowed to add playlists."
      # Playlist
      @webHooks.getForChannel(msg.channel, true)
      .then (hook)=>
        hook.execSlack @hud.addPlaylistWebhook(msg.author, info.length, msg.guild)
      .catch (e)=>
        msg.channel.sendMessage @hud.addPlaylist(msg.author, info.length)
      # Iterate over all items
      return info.forEach (v)=> @handleVideoInfo(v, msg, args, gdata, true)
    # Check if duration is valid
    duration = @parseTime info.duration
       
    if (duration > 1800  and not @permissions.isDJ(msg.author, msg.guild)) or 
       (duration > 7200  and not @permissions.isAdmin(msg.author, msg.guild)) or
       (duration > 43200 and not @permissions.isOwner(msg.author))
       # Bot Owner = ∞
      return msg.reply 'The requested song is too long.' if not silent
      return

    # Get filters
    filters = []
    if args[1] and isFinite duration
      filterR = args[1].split ' '
      for filter in filterR
        try
          f = filter.split '='
          filter = audioFilters.getFilter f[0], f[1]
          if filter
            if filter.isAdminOnly() and not @permissions.isDJ msg.author, msg.guild
              return msg.reply "#{filter} is only for DJs." if not silent
              return
            valErr = filter.validate()
            if valErr
              return msg.reply "#{filter} - #{valErr}" if not silent
              return
            filters.push filter

    omsg = undefined
      # temp
      #filters = [filters[0]]

    filterstr = " "
    filterstr += filter for filter in filters

    {queue, audioPlayer} = gdata
    # Create a new queue item
    qI = new QueueItem {
      title: info.title
      duration
      requestedBy: msg.member
      playInChannel: msg.member.getVoiceChannel()
      filters: filters
      path: info.url
      sauce: info.webpage_url
      thumbnail: info.thumbnail
    }
    # Set events
    durationstr = if isFinite(qI.duration) then moment.utc(qI.duration * 1000).format("HH:mm:ss") else '∞'
    qI.once 'start', =>
      if omsg
        omsg.delete()
        omsg = null
      msg.channel.sendMessage @hud.nowPlaying gdata, qI, true
        .then (m)=>
          if gdata.data.autoDel
           setTimeout (->m.delete()), 15000
    
    qI.once 'end', =>
      setTimeout (()=>
        if not queue.items.length and not queue.currentItem
          try
            msg.channel.sendMessage 'Nothing more to play.'
            .then (m)=>
              if gdata.data.autoDel
                setTimeout (->m.delete()), 15000
            audioPlayer.clean true
      ), 100
    
    if not silent
      # Try to use a WebHook for the "added to queue" message
      @webHooks.getForChannel(msg.channel, true)
      .then (hook)=>
        if gdata.data.autoDel
          msg.delete()
        hook.execSlack @hud.addItemWebhook(msg.guild, qI.requestedBy, qI, queue.items.length)
      # The old method
      .catch (e)=>
        msg.channel.sendMessage @hud.addItem msg.guild, qI.requestedBy, qI, queue.items.length
        .then (m)=>
          omsg = m;
          setTimeout ->
            if omsg and gdata.data.autoDel
              omsg.delete()
              omsg = null
          , 15000
          if gdata.data.autoDel
            msg.delete()
    queue.addToQueue qI

module.exports = PlayerModule

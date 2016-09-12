QueueItem = require '../../models/audioQueueItem'
moment = require 'moment'
reload = require('require-reload')(require)
AudioModuleCommands = reload './commands'
audioFilters = reload '../../filters'
AudioHud = reload './hud'

class PlayerModule extends BotModule
  init: =>
    { @permissions, @getGuildData } = @engine
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

  handleVideoInfo: (info, msg, args)=>
    # Check if duration is valid
    duration = @parseTime info.duration

    if (duration > 1000 and not @permissions.isAdmin msg.author, msg.guild) or 
       duration > 3600 and not @permissions.isOwner msg.author
      return msg.reply 'The requested song is too long.'

    # Get filters
    filters = []
    if args[1] and isFinite duration
      filterR = args[1].split ' '
      for filter in filterR
        try
          f = filter.split '='
          filter = audioFilters.getFilter f[0], f[1]
          if filter
            if filter.isAdminOnly() and not @permissions.isAdmin msg.author, msg.guild
              return msg.reply "#{filter} is only for Bot Commanders."
            valErr = filter.validate()
            if valErr
              return msg.reply "#{filter} - #{valErr}"
            filters.push filter

    omsg = undefined
      # temp
      #filters = [filters[0]]

    filterstr = " "
    filterstr += filter for filter in filters

    {queue, audioPlayer} = @getGuildData(msg.guild)
    # Create a new queue item
    qI = new QueueItem {
      title: info.title
      duration
      requestedBy: msg.member
      playInChannel: msg.member.getVoiceChannel()
      filters: filters
      path: info.url
      sauce: info.webpage_url
    }
    # Set events
    durationstr = if isFinite(qI.duration) then moment.utc(qI.duration * 1000).format("HH:mm:ss") else '∞'
    qI.on 'start', =>
      if omsg
        omsg.delete()
        omsg = null
      msg.channel.sendMessage @hud.nowPlaying msg.guild, qI, true
        .then (m)=>
          setTimeout (->m.delete()), 15000
    
    qI.on 'end', =>
      setTimeout (()=>
        if not queue.items.length and not queue.currentItem
          msg.channel.sendMessage 'Nothing more to play.'
          .then (m)=>
            setTimeout (->m.delete()), 15000
          audioPlayer.clean true
      ), 100
      
    msg.channel.sendMessage @hud.addItem msg.guild, qI.requestedBy, qI, queue.items.length+1
    .then (m)=>
      omsg = m;
      setTimeout ->
        if omsg
          omsg.delete()
          omsg = null
      , 15000
      msg.delete()
    queue.addToQueue qI

module.exports = PlayerModule

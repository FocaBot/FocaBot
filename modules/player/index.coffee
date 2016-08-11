QueueItem = require '../../models/audioQueueItem'
moment = require 'moment'
reload = require('require-reload')(require)
AudioModuleCommands = reload './commands'
audioFilters = reload '../../filters'

class PlayerModule
  constructor: (@engine)->
    { @bot, @permissions, @getServerData } = @engine
    @moduleCommands = new AudioModuleCommands @

  handleVideoInfo: (dl, msg, args)=>
    {info} = dl

    # Check if duration is valid
    duration = (=>
      if info.duration.split(':').length < 2
        parseInt info.duration
      else
        moment.duration(info.duration)
        .asSeconds() /60
    )()
    moment.duration(info.duration).asSeconds()/60

    if (duration > 1000 and not @permissions.isAdmin msg.author, msg.server) or 
       duration > 3600 and not @permissions.isOwner msg.author or
       duration <= 0
      return @bot.reply msg, 'The requested song is too long. (or too short?)'

    # Get filters
    filters = []
    if args[1]
      filterR = args[1].split ' '
      for filter in filterR
        try
          f = filter.split '='
          filter = audioFilters.getFilter f[0], f[1]
          if filter
            if filter.isAdminOnly() and not @permissions.isAdmin msg.author, msg.server
              return @bot.reply msg, "#{filter} is only for Bot Commanders."
            valErr = filter.validate()
            if valErr
              return @bot.reply msg, "#{filter} - #{valErr}"
            filters.push filter
    
      # temp
      #filters = [filters[0]]

    filterstr = " "
      filterstr += filter for filter in filters
    @bot.sendMessage msg.channel, "Loading `#{info.title}` #{filterstr} (#{info.duration})..."
    # Start download
    dl.download()
    .then =>
      {queue, audioPlayer} = @getServerData(msg.server)
      # Create a new queue item
      qI = new QueueItem {
        title: info.title
        duration: info.duration
        requestedBy: msg.author
        playInChannel: msg.author.voiceChannel
        filters: filters
        path: dl.path
      }
      # Set events
      qI.on 'start', =>
        @bot.sendMessage msg.channel, """
          Now Playing In `#{qI.playInChannel.name}`: **#{qI.title}** #{filterstr}

          (Length: `#{qI.duration}` - Requested By **#{qI.requestedBy}**)
          """
      qI.on 'end', =>
        dl.deleteFiles()
        setTimeout (()=>
          if not queue.items.length and not queue.currentItem
            @bot.sendMessage msg.channel, 'Nothing more to play.'
            audioPlayer.clean true
        ), 100
      
      @bot.sendMessage msg.channel, "**#{msg.author}** added `#{qI.title}` #{filterstr} (#{qI.duration}) to the queue! (Position \##{queue.items.length+1})"
      queue.addToQueue qI
    .catch (err)=>
      @bot.sendMessage msg.channel, 'Something went wrong.'
      dl.deleteFiles()
        
  shutdown: =>
    @moduleCommands.unregisterAll

module.exports = PlayerModule

reload = require('require-reload')(require)
youtubedl = require 'youtube-dl'
{ spawn } = require 'child_process'
moment = require 'moment'

class AudioModuleCommands
  constructor: (@audioModule)->
    { @engine, @registerCommand, @hud, @audioFilters } = @audioModule
    { @getGuildData, @permissions } = @engine

    # Play
    @registerCommand 'play', { argSeparator: '|' }, (msg,args)=>
      return msg.reply 'No video specified.' if not args[0].trim() and not msg.attachments[0]
      return msg.reply 'You must be in a voice channel to request songs.' if not msg.member.getVoiceChannel()
      urlToFind = args[0]
      if msg.attachments[0]
        urlToFind  = msg.attachments[0].url
      youtubedl.getInfo urlToFind, ['--default-search', 'ytsearch', '-f', 'bestaudio', '--no-playlist'], (err, info) =>
        if err
          return youtubedl.getInfo urlToFind, [], (error, info) =>
            return msg.reply 'Something went wrong.' if error
            @audioModule.handleVideoInfo info, msg, args
        if isNaN info.duration
          # Try to get the duration from FFProbe (for direct links and other streams)
          ffprobe = spawn('ffprobe', [info.url, '-show_format', '-v', 'quiet'])
          ffprobe.stdout.on 'data', (data)=>
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
            @audioModule.handleVideoInfo info, msg, args
        else @audioModule.handleVideoInfo info, msg, args
    
    # Skip
    @registerCommand 'skip', (msg)=>
      {queue} = @getGuildData(msg.guild)
      return if msg.author.bot
      return msg.reply 'You must be in a voice channel.' if not msg.member.getVoiceChannel()
      target = Math.round(msg.member.getVoiceChannel().members.length * 0.4)
      if queue.items.length or queue.currentItem
        if not @permissions.isDJ(msg.author, msg.guild) and msg.author.id isnt queue.currentItem.requestedBy.id 

          if msg.author.id in queue.currentItem.voteSkip
            return msg.reply 'Did you really try to skip this song **again**?'
          else
            queue.currentItem.voteSkip.push msg.author.id
            ql = queue.currentItem.voteSkip.length
            msg.channel.sendMessage "**#{msg.member.nick or msg.author.username}** voted to skip the current song (#{ql}/#{target})"

        if (queue.currentItem.voteSkip.length >= target) or msg.author.id is queue.currentItem.requestedBy.id or @permissions.isDJ msg.author, msg.guild
          msg.channel.sendMessage "**#{msg.member.nick or msg.author.username}** skipped the current song."
          queue.nextItem()
      else
        msg.channel.sendMessage 'No songs playing on the current server.'

    # Stop
    @registerCommand 'stop', { djOnly: true }, (msg)=>
      {queue} = @getGuildData(msg.guild)
      if queue.currentItem
        queue.clearQueue()
        msg.channel.sendMessage "**#{msg.member.nick or msg.author.username}** cleared the queue."
      else
        msg.channel.sendMessage "No songs playing on the current server."

    # Volume
    @registerCommand 'volume', { djOnly: true }, (msg, args)=>
      {audioPlayer} = @getGuildData(msg.guild)
      if not args
        return msg.channel.sendMessage @hud.getVolume msg.guild
      volume = parseInt(args)
      if volume > 0 and volume <=100
        audioPlayer.setVolume volume
        msg.channel.sendMessage @hud.setVolume msg.guild, msg.member
      else
        msg.channel.sendMessage "Invalid volume provided."

    
    # Queue
    @registerCommand 'queue', (msg, args)=>
      {audioPlayer, queue} = @getGuildData(msg.guild)
      return msg.channel.sendMessage "Nothing being played on the current server." if not queue.currentItem
      msg.channel.sendMessage @hud.queue msg.guild, parseInt args
      .then (m)=>
        msg.delete()
        setTimeout (->m.delete()), 15000

    # Undo
    @registerCommand 'undo', (msg, args)=>
      {queue} = @getGuildData msg.guild
      if not queue.items.length and not queue.currentItem
        return msg.channel.sendMessage 'The queue is empty.'

      [..., last] = queue.items
      last = queue.currentItem if not last
      if last.requestedBy.id is msg.author.id or @permissions.isDJ msg.author, msg.guild
        msg.channel.sendMessage @hud.removeItem msg.guild, msg.member, last
        queue.undo()
      else
        msg.channel.sendMessage 'You can only remove your own items from the queue.'

    # Shuffle
    @registerCommand 'shuffle', {
      description: 'Shuffles the queue.'
      djOnly: true
    }, (msg,args)=>
      {queue} = @getGuildData msg.guild
      if queue.items.length
        queue.shuffle()
        msg.channel.sendMessage '✅'
      else
        msg.channel.sendMessage 'The queue is empty.'

    # Now Playing
    @registerCommand 'np', (msg, args)=>
      {audioPlayer, queue} = @getGuildData(msg.guild)
      msg.channel.sendMessage @hud.nowPlaying msg.guild, queue.currentItem, false
      .then (m)=>
        msg.delete()
        setTimeout (->m.delete()), 10000

    # Sauce
    @registerCommand 'sauce', (msg, args)=>
      {audioPlayer, queue} = @getGuildData(msg.guild)
      return msg.channel.sendMessage "Nothing being played on the current server." if not queue.currentItem
      qI = queue.currentItem
      return msg.reply "Sorry, no sauce for the current item. :C" if not qI.sauce
      msg.reply "Here's the sauce of the current item: #{qI.sauce}"
      .then (m)=>
        msg.delete()
        setTimeout (->m.delete()), 20000

    # Remove
    @registerCommand 'remove', (msg, args)=>
      {queue} = @getGuildData msg.guild
      index = (parseInt args) - 1
      itm = queue.items[index]
      if not itm
        return msg.channel.sendMessage "Can't find the specified item in the queue."
      
      if itm.requestedBy.id is msg.author.id or @permissions.isDJ msg.author, msg.guild
        msg.channel.sendMessage @hud.removeItem msg.guild, msg.member, itm
        .then (m)=>
          msg.delete()
          setTimeout (->m.delete()), 10000
        queue.remove index
      else
        msg.channel.sendMessage 'You can only remove your own items from the queue.'

    # Swap
    @registerCommand 'swap', { djOnly: true, argSeparator: ' ' }, (msg,args)=>
      {queue} = @getGuildData msg.guild
      return msg.channel.sendMessage "Invalid arguments provided." if args.length < 2
      indexes = [parseInt(args[0])-1, parseInt(args[1])-1]
      for idx of indexes
        return msg.channel.sendMessage "Can't find the specified items in the queue." if not queue.items[idx]
      items = queue.swap indexes[0], indexes[1]
      msg.channel.sendMessage @hud.swapItems msg.guild, msg.member, items, indexes
      .then (m)=>
        msg.delete()
        setTimeout (->m.delete()), 10000

    # Change Filters
    @registerCommand 'fx', { aliases: ['setfilters', '|'], argSeparator: ' ' }, (msg,args)=>
      {queue} = @getGuildData msg.guild
      return if not isFinite queue.currentItem.duration
      return if not @permissions.isDJ(msg.author, msg.guild) and msg.author.id isnt queue.currentItem.requestedBy.id
      for filter in queue.currentItem.filters
        return msg.reply "The filter #{filter} cannot be removed while the song plays." if filter.avoidRuntime
      filters = []
      for filter in args
        try
          f = filter.split '='
          filter = @audioFilters.getFilter f[0], f[1]
          if filter
            if filter.isAdminOnly() and not @permissions.isDJ msg.author, msg.guild
              return msg.reply "#{filter} is only for DJs."
            return msg.reply "The filter #{filter} cannot be applied while the song plays." if filter.avoidRuntime
            valErr = filter.validate()
            if valErr
              return msg.reply "#{filter} - #{valErr}"
            filters.push filter
        catch e
          console.error e
      queue.updateFilters filters

    # Seek
    @registerCommand 'seek', (msg,args)=>
      {queue} = @getGuildData msg.guild
      return if not @permissions.isDJ(msg.author, msg.guild) and msg.author.id isnt queue.currentItem.requestedBy.id
      for filter in queue.currentItem.filters
        return msg.reply "You can't seek through this song (unsupported filter #{filter})." if filter.avoidRuntime
      return msg.reply "You can't seek to that position" if @parseTime(args) > queue.currentItem.duration or @parseTime(args) < 1
      queue.seek @parseTime(args), true

  # TODO: At this point, this should be in a global function or something
  parseTime:(time)=>
    t = time.split(':').reverse()
    moment.duration {
      seconds: t[0]
      minutes: t[1]
      hours:   t[2]
    }
    .asSeconds()

module.exports = AudioModuleCommands

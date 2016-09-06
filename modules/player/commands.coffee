reload = require('require-reload')(require)
youtubedl = require 'youtube-dl'
moment = require 'moment'

class AudioModuleCommands
  constructor: (@audioModule)->
    { @engine, @registerCommand } = @audioModule
    { @getGuildData, @permissions } = @engine

    # Play
    @registerCommand 'play', { argSeparator: '|' }, (msg,args)=>
      return msg.reply 'No video specified.' if not args[0].trim()
      return msg.reply 'You must be in a voice channel to request songs.' if not msg.member.getVoiceChannel()
      urlToFind = args[0]
      if msg.attachments[0]
        urlToFind  = msg.attachments[0].url
      youtubedl.getInfo urlToFind, ['--default-search', 'ytsearch', '-f', 'bestaudio', '--no-playlist'], (err, info) =>
        if err
          return youtubedl.getInfo urlToFind, [], (error, info) =>
            return msg.reply 'Something went wrong.' if error
            @audioModule.handleVideoInfo info, msg, args
        @audioModule.handleVideoInfo info, msg, args        
    
    # Skip
    @registerCommand 'skip', (msg)=>
      {queue} = @getGuildData(msg.guild)
      return if msg.author.bot
      return msg.reply 'You must be in a voice channel.' if not msg.member.getVoiceChannel()
      target = Math.round(msg.member.getVoiceChannel().members.length * 0.4) + 1
      if queue.items.length or queue.currentItem
        if not @permissions.isAdmin msg.author, msg.guild

          if msg.author.id in queue.currentItem.voteSkip
            return msg.reply 'Did you really try to skip this song **again**?'
          else
            queue.currentItem.voteSkip.push msg.author.id
            ql = queue.currentItem.voteSkip.length
            msg.channel.sendMessage "**#{msg.member.nick or msg.author.username}** voted to skip the current song (#{ql}/#{target})"

        if (queue.currentItem.voteSkip.length >= target) or @permissions.isAdmin msg.author, msg.guild
          msg.channel.sendMessage "**#{msg.member.nick or msg.author.username}** skipped the current song."
          queue.nextItem()
      else
        msg.channel.sendMessage 'No songs playing on the current server.'

    # Stop
    @registerCommand 'stop', { adminOnly: true }, (msg)=>
      {queue} = @getGuildData(msg.guild)
      if queue.currentItem
        queue.clearQueue()
        msg.channel.sendMessage "**#{msg.member.nick or msg.author.username}** cleared the queue."
      else
        msg.channel.sendMessage "No songs playing on the current server."

    # Volume
    @registerCommand 'volume', { adminOnly: true }, (msg, args)=>
      {audioPlayer} = @getGuildData(msg.guild)
      if not args
        return msg.channel.sendMessage "Current Volume: #{audioPlayer.volume}."
      volume = parseInt(args)
      if volume > 0 and volume <=100
        audioPlayer.setVolume volume
        msg.channel.sendMessage "**#{msg.member.nick or msg.author.username}** set the volume to #{volume}."
      else
        msg.channel.sendMessage "Invalid volume provided."

    
    # Queue
    @registerCommand 'queue', (msg, args)=>
      {audioPlayer, queue} = @getGuildData(msg.guild)
      return msg.channel.sendMessage "Nothing being played on the current server." if not queue.currentItem
      qI = queue.currentItem
      currentTime = moment.utc(audioPlayer.encStream.timestamp * 1000).format("HH:mm:ss")
      durationstr = if isFinite(qI.duration) then moment.utc(qI.duration * 1000).format("HH:mm:ss") else '∞'
      filterstr = ""
      filterstr += filter for filter in qI.filters
      reply = """
        Now Playing in `#{qI.playInChannel.name}`:
        ```fix
        live
        ```
        #{filterstr}
        Length: `#{durationstr}`
        Requested By **#{qI.requestedBy.nick or qI.requestedBy.username}**
        """
      if queue.items.length
        reply += "\n\n**Up next:**\n"
        l = queue.items.length
        i = 0
        for qi in queue.items when i < 20
          filterstr = ""
          filterstr += filter for filter in qi.filters
          durationstr = if isFinite(qi.duration) then moment.utc(qi.duration * 1000).format("HH:mm:ss") else '∞'
          reply += "**#{++i}.** `#{qi.title}` #{filterstr} (#{durationstr}) Requested By #{qI.requestedBy.nick or qI.requestedBy.username}\n"
        if l > 15
          reply += "*(#{l-i} more...)*"
      else
         reply += "\nQueue is currently empty."
      msg.channel.sendMessage reply
      .then (m)=>
        msg.delete()
        setTimeout (->m.delete()), 15000

    # Undo
    @registerCommand 'undo', {
      description: 'Removes the last item from the queue.'
    }, (msg, args)=>
      {queue} = @getGuildData msg.guild
      if not queue.items.length and not queue.currentItem
        return msg.channel.sendMessage 'The queue is empty.'

      [..., last] = queue.items
      last = queue.currentItem if not last
      if last.requestedBy.id is msg.author.id or @permissions.isAdmin msg.author, msg.guild
        queue.undo()
        msg.channel.sendMessage "**#{msg.member.nick or msg.author.username}** removed the last item from the queue."
      else
        msg.channel.sendMessage 'You can only remove your own items from the queue.'

    # Shuffle
    @registerCommand 'shuffle', {
      description: 'Shuffles the queue.'
      adminOnly: true
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
      return msg.channel.sendMessage "Nothing being played on the current server." if not queue.currentItem
      qI = queue.currentItem
      currentTime = moment.utc(audioPlayer.encStream.timestamp * 1000).format("HH:mm:ss")
      durationstr = if isFinite(qI.duration) then moment.utc(qI.duration * 1000).format("HH:mm:ss") else '∞'
      filterstr = ""
      filterstr += filter for filter in qI.filters
      msg.channel.sendMessage """
        Now Playing in `#{qI.playInChannel.name}`:
        ```fix
        live
        ```
        #{filterstr}
        Length: `#{durationstr}`
        Requested By **#{qI.requestedBy.nick or qI.requestedBy.username}**
        """
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
        setTimeout (->m.delete()), 15000

module.exports = AudioModuleCommands

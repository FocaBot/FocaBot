reload = require('require-reload')(require)
youtubedl = require 'youtube-dl'
promisify = require 'es6-promisify'
getInfo = promisify(youtubedl.getInfo)
{ delay } = Core.util

class AudioModuleCommands
  constructor: (@audioModule)->
    { @q, @hud } = @audioModule
    { @permissions } = Core
    { @parseTime } = Core.util
    @m = @audioModule

    # Play
    @m.registerCommand 'play', { aliases: ['p'], argSeparator: '|' }, (msg,args,data)=>
      return msg.reply 'No video specified.' unless args[0].trim() and not msg.attachments[0]
      unless msg.member.getVoiceChannel()
        return msg.reply 'You must be in a voice channel to request songs.'
      # Use first attachment if present
      if msg.attachments[0] then urlToFind = msg.attachments[0].url
      else urlToFind = args[0]
      try
        # Get info from the URL using ytdl
        info = await getInfo(urlToFind, [
          '--default-search', 'ytsearch', '-f', 'bestaudio'
        ], { maxBuffer: Infinity })
      catch
        # probably not a YT link, try again without flags
        try info = await getInfo(urlToFind, [], { maxBuffer: Infinity })
        catch
          msg.reply 'Something went wrong.'
      @audioModule.handleVideoInfo info, msg, args, data

    # Skip
    @m.registerCommand 'skip', (msg, args, d)=>
      queue = await @q.getForGuild(msg.guild)
      msg.delete() if d.data.autoDel
      u = msg.member.nick or msg.author.username
      # Some checks
      return if msg.author.bot
      unless queue.items.length or queue.nowPlaying
        return msg.reply 'Nothing being played in this server.'
      # Instant skip for DJs and people who requested the current element
      if @permissions.isDJ(msg.member) or msg.author is queue.nowPlaying.requestedBy.id
        msg.channel.sendMessage "**#{u}** skipped the current song."
        return queue.nextItem()
      return msg.reply 'You are not allowed to skip songs.' unless d.data.voteSkip
      # Vote skip if enabled
      Core.commands.plain.voteskip.exec(msg, args, d)

    @m.registerCommand 'voteskip', { aliases: ['vs'] }, (msg, args, d)=>
      return msg.reply 'You are not allowed to skip songs.' unless d.data.voteSkip
      return msg.reply 'You must be in a voice channel.' unless msg.member.getVoiceChannel()
      if queue.nowPlaying.voiceChannel.id isnt msg.member.getVoiceChannel().id
        return msg.reply 'You must be in the same voice channel the bot is in.'
      queue.nowPlaying.voteSkip = [] unless queue.nowPlaying.voteSkip

      if msg.author.id in queue.nowPlaying.voteSkip
        return msg.reply 'Did you really try to skip this song **again**?'
      # Democracy!
      # ~40% of channel members
      targetVotes = Math.round(queue.nowPlaying.voiceChannel.members.length * 0.4)
      queue.nowPlaying.voteSkip.push(msg.author.id)
      votes = queue.nowPlaying.voteSkip.length
      msg.channel.sendMessage """
      **#{u}** voted to skip the current song (#{votes}/#{targetVotes})
      """

      if votes >= targetVotes
        msg.channel.sendMessage 'Skipping current song ~~with the power of democracy~~.'
        queue.nextItem()

    # Clear / Stop
    @m.registerCommand 'clear', { aliases: ['stop'], djOnly: true }, (msg)=>
      queue = await @q.getForGuild msg.guild
      queue.clearQueue()
      msg.channel.sendMessage 'Queue cleared.'

    # Pause
    @m.registerCommand 'pause', { djOnly: true }, (msg)=>
      queue = await @q.getForGuild msg.guild
      unless isFinite(queue.nowPlaying.duration) and queue.nowPlaying.duration > 0
        return msg.reply "You can't pause streams."
      if queue.nowPlaying.filters
        for filter in queue.nowPlaying.filters
          return msg.reply """
          You can't pause this song (static filter #{filter.display}).
          """ if filter.avoidRuntime
      queue.pause()

    # Resume
    @m.registerCommand 'resume', { djOnly: true }, (msg)=>
      queue = await @q.getForGuild msg.guild
      queue.resume()

    # Now Playing (np)
    @m.registerCommand 'np', { aliases: ['nowplaying', 'n'] }, (msg, args, d)=>
      queue = await @q.getForGuild msg.guild
      return 'Nothing being played.' unless queue.nowPlaying
      m = await msg.channel.sendMessage(
        "Now playing in `#{queue.nowPlaying.voiceChannel.name}`:",
        false, await @hud.nowPlayingEmbed(queue, queue.nowPlaying)
      )
      if d.data.autoDel
        msg.delete()
        await delay(15000)
        m.delete()

    # View Queue
    @m.registerCommand 'queue', { aliases: ['q'] }, (msg, args, d)=>
      queue = await @q.getForGuild msg.guild
      m = await msg.channel.sendMessage await @hud.nowPlaying(queue, queue.nowPlaying),
                                        false,
                                        @hud.queue(queue, parseInt(args) or 1)
      if d.data.autoDel
        msg.delete()
        await delay(30000)
        m.delete()

    # Shuffle
    @m.registerCommand 'shuffle', { djOnly: true }, (msg, args, d)=>
      queue = await @q.getForGuild msg.guild
      if queue.items.length
        queue.shuffle()
        msg.channel.sendMessage '✅'
      else
        m = await msg.channel.sendMessage 'The queue is empty.'
        await delay(5000)
        m.delete() if d.data.autoDel

    # Sauce
    @m.registerCommand 'sauce', { aliases: ['source', 'src'] }, (msg, args, d)=>
      queue = await @q.getForGuild msg.guild
      unless queue.nowPlaying
        return msg.channel.sendMessage 'Nothing being played on the current server.'
      unless queue.nowPlaying.sauce
        m = await msg.reply 'Sorry, no sauce for the current item. :C'
      else m = await msg.reply "Here's the sauce of the current item: #{queue.nowPlaying.sauce}"
      await delay(15000)
      m.delete() if d.data.autoDel

    # Remove Last / Undo
    @m.registerCommand 'removelast', { aliases: ['undo', 'rl'] }, (msg, args, d)=>
      queue = await @q.getForGuild msg.guild
      return msg.channel.sendMessage 'The queue is empty.' if not queue.items.length
      [..., last] = queue.items
      if last.requestedBy.id is msg.author.id or @permissions.isDJ msg.author, msg.guild
        item = queue.items[queue.items.length-1]
        msg.channel.sendMessage 'Removed from the queue:',
                                false,
                                @hud.removeItem(item, msg.member)
        queue.removeLast()
      else
        m = await msg.channel.sendMessage 'You can only remove your own items from the queue.'
        await delay(5000)
        m.delete() if d.data.autoDel

    # Remove
    @m.registerCommand 'remove', { aliases: ['rm'] }, (msg, args, d)=>
      queue = await @q.getForGuild msg.guild
      index = (parseInt args) - 1
      itm = queue.items[index]
      if itm
        if itm.requestedBy.id is msg.author.id or @permissions.isDJ msg.author, msg.guild
          item = queue.items[index]
          msg.channel.sendMessage 'Removed from the queue:',
                                  false,
                                  @hud.removeItem(item, msg.member)
          queue.remove(index)
        else
          m = msg.channel.sendMessage 'You can only remove your own items from the queue.'
          await delay(5000)
          m.delete() if d.data.autoDel
      else
        m = await msg.channel.sendMessage "Can't find the specified item in the queue."
        await delay(5000)
        m.delete() if d.data.autoDel

    # Swap
    @m.registerCommand 'swap', {
      aliases: ['sw'], djOnly: true, argSeparator: ' '
    }, (msg, args, d)=>
      queue = await @q.getForGuild msg.guild
      return msg.channel.sendMessage 'Invalid arguments provided.' unless args.length is 2
      indexes = [parseInt(args[0])-1, parseInt(args[1])-1]
      for idx of indexes
        unless queue.items[idx]?
          return msg.channel.sendMessage "Can't find the specified items in the queue."
      items = queue.swap(indexes[0], indexes[1])
      msg.channel.sendMessage @hud.swapItems msg.member, items, indexes

    # Move
    @m.registerCommand 'move', {
      aliases: ['mv'], djOnly: true, argSeparator: ' '
    }, (msg, args)=>
      queue = await @q.getForGuild msg.guild
      return msg.channel.sendMessage 'Invalid arguments provided.' unless args.length is 2
      indexes = [parseInt(args[0])-1, parseInt(args[1])-1]
      for idx of indexes
        unless queue.items[idx]
          return msg.channel.sendMessage "Can't find the specified items in the queue."
      item = queue.move indexes[0], indexes[1]
      msg.channel.sendMessage @hud.moveItem msg.member, item, indexes

    # Seek
    @m.registerCommand 'seek', { aliases: ['s'] }, (msg, args)=>
      queue = await @q.getForGuild msg.guild
      return unless isFinite queue.nowPlaying.duration and queue.nowPlaying.duration > 0
      return unless @permissions.isDJ(msg.author, msg.guild) or
                    msg.author.id is queue.nowPlaying.requestedBy.id
      if queue.nowPlaying.filters
        for filter in queue.nowPlaying.filters
          return msg.reply """
          You can't seek through this song (static filter #{filter.display}).
          """ if filter.avoidRuntime
      if @parseTime(args) > queue.nowPlaying.duration or @parseTime(args) < 0
        return msg.reply "You can't seek to that position"
      queue.seek @parseTime(args)

    # Update Filters
    @m.registerCommand 'fx', { aliases: ['setfilters', 'updatefilters', '|'] }, (msg, args)=>
      queue = await @q.getForGuild msg.guild
      return unless isFinite(queue.nowPlaying.duration) and queue.nowPlaying.duration > 0
      return unless @permissions.isDJ(msg.author, msg.guild) or
                    msg.author.id isnt queue.nowPlaying.requestedBy.id
      if queue.nowPlaying.filters
        for filter in queue.nowPlaying.filters
          return msg.reply """
          The static filter #{filter.display} avoids further filter changes.
          """ if filter.avoidRuntime
      try
        filters = @m.getFilters(args, msg.member, true)
      catch e
        if typeof e is 'string'
          return msg.reply 'A filter reported errors:', false, {
            description: e,
            color: 0xFF0000
          }
        else Core.log e,2
      queue.updateFilters queue.nowPlaying, filters

module.exports = AudioModuleCommands

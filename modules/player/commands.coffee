{ delay, parseTime } = Core.util
{ commands } = Core

class PlayerCommands
  constructor: (@playerModule)->
    { @hud, @util, @registerCommand } = @playerModule
    { @permissions } = Core

    # Play
    @registerCommand 'play', { aliases: ['p', 'request', 'add'] }, (m , args, d, player)=>
      # Parse user input
      title = args.split('|')[0].trim()
      filters = (args.split('|')[1] or '').trim()
      if args.match(/@\s?(\d+(:\d+)*)/)
        time = parseTime(args.match(/@\s?(\d+(:\d+)*)/)[1])
        title = title.replace(/@\s?(\d+(:\d+)*)/, '').trim()
        filters = filters.replace(/@\s?(\d+(:\d+)*)/, '').trim()
      title = m.attachments[0].url if m.attachments[0]
      return m.reply 'No video specified.' unless title
      # Check Voice Connection
      unless m.member.getVoiceChannel()
        return m.reply 'You must be in a voice channel to request songs.'
      try
        # Get Video Information
        info = await @util.getInfo(title)
        info.startAt = time or 0
        if info.startAt > info.duration or info.startAt < 0
          return m.reply 'Invalid start time.'
        if info.forEach # Playlist
          await @util.processPlaylist(info, m, '', d, player)
        else # Video
          @util.processInfo(info, m, '', d, player)
      catch e
        m.reply 'Something went wrong.', false, {
          color: 0xAA3300
          # Windows 10 installer flashbacks
          description: e.message.split('ERROR:')[1] or 'Something went wrong.'
        }

    # Skip
    @registerCommand 'skip', (msg, args, d, player)=>
      msg.delete() if d.data.autoDel
      # Some checks
      return if msg.author.bot
      unless player.queue._d.items.length or player.queue._d.nowPlaying
        return msg.reply 'Nothing being played in this server.'
      # Instant skip for DJs and people who requested the current element
      if @permissions.isDJ(msg.member) or msg.author is player.queue.nowPlaying.requestedBy
        msg.channel.sendMessage "**#{msg.member.name}** skipped the current song."
        return player.skip()
      return msg.reply 'You are not allowed to skip songs.' unless d.data.voteSkip
      # Vote skip if enabled
      commands.run('voteskip', msg, args)

    @registerCommand 'voteskip', { aliases: ['vs'] }, (msg, args, d, player)=>
      msg.delete() if d.data.autoDel
      return msg.reply 'You are not allowed to skip songs.' unless d.data.voteSkip
      return msg.reply 'You must be in a voice channel.' unless msg.member.getVoiceChannel()
      unless player.queue.nowPlaying.voiceChannel is msg.member.getVoiceChannel()
        return msg.reply 'You must be in the same voice channel the bot is in.'
      if msg.author.id in player.queue.nowPlaying.voteSkip
        return msg.reply 'Did you really try to skip this song **again**?'
      # Democracy!
      # ~40% of channel members
      targetVotes = Math.round(player.queue.nowPlaying.voiceChannel.members.length * 0.4)
      player.queue._d.nowPlaying.voteSkip.push(msg.author.id)
      votes = player.queue._d.nowPlaying.voteSkip.length
      msg.channel.sendMessage """
      **#{msg.member.name}** voted to skip the current song (#{votes}/#{targetVotes})
      """

      if votes >= targetVotes
        msg.channel.sendMessage 'Skipping current song ~~with the power of democracy~~.'
        player.skip()

    # Clear / Stop
    @registerCommand 'clear', { aliases: ['stop'], djOnly: true }, (msg, a, d, player)=>
      player.stop()
      msg.channel.sendMessage 'Queue cleared.'

    # Pause
    @registerCommand 'pause', { djOnly: true }, (msg, a, d, player)=>
      try player.pause()
      catch e
        msg.reply e.message if e.message

    # Resume
    @registerCommand 'resume', { djOnly: true }, (msg, a , d, player)=>
      player.play()

    # Now Playing (np)
    @registerCommand 'np', { aliases: ['nowplaying', 'n'] }, (msg, a, d, player)=>
      return 'Nothing being played.' unless player.queue._d.nowPlaying
      m = await msg.channel.sendMessage(
        "Now playing in `#{player.queue.nowPlaying.voiceChannel.name}`:",
        false, await @hud.nowPlayingEmbed(player.queue.nowPlaying)
      )
      if d.data.autoDel
        msg.delete()
        await delay(15000)
        m.delete()

    # View Queue
    @registerCommand 'queue', { aliases: ['q'] }, (msg, args, d, player)=>
      return 'Nothing being played.' unless player.queue._d.nowPlaying
      m = await msg.channel.sendMessage await @hud.nowPlaying(player.queue.nowPlaying),
                                        false,
                                        @hud.queue(player.queue, parseInt(args) or 1)
      if d.data.autoDel
        msg.delete()
        await delay(30000)
        m.delete()

    # Shuffle
    @registerCommand 'shuffle', { djOnly: true }, (msg, a, d, player)=>
      return msg.channel.sendMessage 'The queue is empty.' unless player.queue._d.items.length
      player.queue.shuffle()
      msg.channel.sendMessage '✅'

    # Sauce
    @registerCommand 'sauce', { aliases: ['source', 'src'] }, (msg, args, d, player)=>
      return '¯\_(ツ)_/¯' unless player.queue._d.nowPlaying
      unless player.queue._d.nowPlaying.sauce
        return msg.reply 'Sorry, no sauce for the current item. :C'
      m = await msg.reply """
      Here's the sauce of the current item: #{player.queue._d.nowPlaying.sauce}
      """
      await delay(15000)
      m.delete() if d.data.autoDel

    # Remove Last / Undo
    @registerCommand 'removelast', { aliases: ['undo', 'rl'] }, (msg, args, d, player)=>
      return msg.channel.sendMessage 'The queue is empty.' unless player.queue._d.items.length
      commands.run('remove', msg, player.queue._d.items.length)

    # Remove
    @registerCommand 'remove', { aliases: ['rm'] }, (msg, args, d, player)=>
      index = (parseInt args) - 1
      itm = player.queue._d.items[index]
      unless itm
        return msg.channel.sendMessage "Can't find the specified item in the queue."
      unless itm.requestedBy is msg.author.id or @permissions.isDJ msg.member
        return msg.channel.sendMessage 'You can only remove your own items from the queue.'
      { item } = player.queue.remove(index, msg.member)
      msg.channel.sendMessage 'Removed from the queue:',
                              false,
                              @hud.removeItem(item, msg.member)

    # Swap
    @registerCommand 'swap', {
      aliases: ['sp'], djOnly: true, argSeparator: ' '
    }, (msg, args, d, player)=>
      return msg.channel.sendMessage 'Invalid arguments provided.' unless args.length is 2
      result = player.queue.swap(parseInt(args[0])-1, parseInt(args[1])-1, msg.member)
      return msg.reply 'Something went wrong' unless result
      msg.channel.sendMessage @hud.swapItems msg.member, result.items,
                              [result.index1, result.index2]

    # Move
    @registerCommand 'move', {
      aliases: ['mv'], djOnly: true, argSeparator: ' '
    }, (msg, args, d, player)=>
      return msg.channel.sendMessage 'Invalid arguments provided.' unless args.length is 2
      result = player.queue.move(parseInt(args[0])-1, parseInt(args[1])-1, msg.member)
      return msg.reply 'Something went wrong' unless result
      msg.channel.sendMessage @hud.moveItem msg.member, result.item,
                              [result.index, result.position]

    # Move to first place
    @registerCommand 'bump', { djOnly: true }, (msg, args, d, player)=>
      return msg.channel.sendMessage 'Invalid arguments provided.' unless parseInt(args) > 0
      result = player.queue.bump(parseInt(args)-1, msg.member)
      return msg.reply 'Something went wrong' unless result
      msg.channel.sendMessage @hud.moveItem msg.member, result.item,
                              [result.index, result.position]

    # Seek
    @registerCommand 'seek', { aliases: ['s'], djOnly: true }, (msg, args, d, player)=>
      try
        player.seek(parseTime(args))
      catch e
        msg.reply e.message if e.message

###

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

###

module.exports = PlayerCommands

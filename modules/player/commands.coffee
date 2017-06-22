{ delay, parseTime } = Core.util
{ commands } = Core

class PlayerCommands
  constructor: (@playerModule)->
    { @hud, @util } = @playerModule
    { @permissions } = Core

    # Play
    @registerCommand 'play', { aliases: ['p', 'request', 'add'] }, ({ m, args, s, player, l })=>
      # Check Voice Connection
      unless m.member.voiceChannel
        return m.reply l.player.noVoice
      # Check voice channel name
      if s.voiceChannel and s.voiceChannel isnt '*' and
         s.voiceChannel isnt m.member.voiceChannel.name and not @permissions.isAdmin(m.member)
        return m.reply l.player.notAllowed
      # Check item limit
      if @util.checkItemCountLimit(player, m.member)
        return m.reply l.player.queueLimit
      # Process request
      q = args.split('|')[0].trim()
      # Use Attachment URL if present
      q = m.attachments[0].url if m.attachments[0]
      # Filters
      filters = (args.split('|')[1] or '').trim()
      # Start Position
      time = 0
      if args.match(/@\s?(\d+(:\d+)*)/)
        time = parseTime(args.match(/@\s?(\d+(:\d+)*)/)[1])
        q = q.replace(/@\s?(\d+(:\d+)*)/, '').trim()
        filters = filters.replace(/@\s?(\d+(:\d+)*)/, '').trim()
      try
        info = await @util.getInfo(q)
        unless info.partial
          # Single video
          vid = await @util.getAdditionalMetadata(info.items[0])
          if time > vid.duration or time < 0
            return m.reply l.player.invalidStart
          vid.startAt = time
          vid.filters = filters
          @util.processInfo(vid, m, player, false, m.member.voiceChannel)
        else
          # Playlist
          return m.reply(l.player.playlistNoDJ) unless Core.permissions.isDJ(m.member)
          # Allow only one playlist at once
          if player.pendingPlaylist?
            info.cancel()
            return m.reply(l.player.playlistAlreadyLoading)
          @hud.addPlaylist(m.member, info, m.channel, l, s)
          player.pendingPlaylist = { pl: info, by: m.member }
          info.on 'done', =>
            return if info.cancelled
            info.items.forEach (item, i)=>
              vid = await @util.getAdditionalMetadata(item)
              return if time > vid.duration or time < 0
              vid.startAt = time
              vid.filters = filters
              @util.processInfo(vid, m, player, true, m.member.voiceChannel)
              # Start playback if not started already
              if i is (info.items.length - 1) and not player.queue.nowPlaying
                player.queue._d.nowPlaying = player.queue._d.items.shift()
                player.play()
      catch e
        console.error e
        m.reply '', embed: {
          color: 0xAA3300
          # Windows 10 installer flashbacks
          description: e.message.split('YouTube said:')[1] or l.generic.error
        }

    # Skip
    @registerCommand 'skip', ({ m, args, s, player, l })=>
      try m.delete() if s.autoDel
      # Some checks
      return if m.author.bot
      unless player.queue._d.items.length or player.queue._d.nowPlaying
        return m.reply l.player.notPlaying
      # Instant skip for DJs and people who requested the current element
      if @permissions.isDJ(m.member) or m.author.id is player.queue._d.nowPlaying.requestedBy
        m.channel.send l.gen(l.player.skip, m.member.displayName)
        return player.skip()
      return m.reply l.player.noSkipAllowed unless s.voteSkip
      # Vote skip if enabled
      commands.run('voteskip', m, args)

    @registerCommand 'voteskip', { aliases: ['vs'] }, ({ msg, args, s, player, l })=>
      try msg.delete() if s.autoDel
      return msg.reply l.player.noSkipAllowed unless s.voteSkip
      return msg.reply l.player.noVoice unless msg.member.voiceChannel
      unless player.queue.nowPlaying.voiceChannel is msg.member.voiceChannel
        return msg.reply l.player.noSameVoice
      if msg.author.id in player.queue.nowPlaying.voteSkip
        return msg.reply l.player.alreadyVoted
      # Democracy!
      # ~40% of channel members
      targetVotes = Math.round(
        player.queue.nowPlaying.voiceChannel.members.array().length * 0.4
      )
      player.queue._d.nowPlaying.voteSkip.push(msg.author.id)
      votes = player.queue._d.nowPlaying.voteSkip.length
      msg.channel.send l.gen(l.player.voteSkip, msg.member.displayName, votes, targetVotes)

      if votes >= targetVotes
        msg.channel.send l.player.voteSkipSuccess
        player.skip()

    # Clear / Stop
    @registerCommand 'clear', { aliases: ['stop'], djOnly: true }, ({ msg, player, l })=>
      player.stop()
      msg.channel.sendMessage l.player.queueCleared

    # Pause
    @registerCommand 'pause', { djOnly: true }, ({ msg, player })=>
      try await player.pause()
      catch e
        msg.reply e.message if e.message

    # Resume
    @registerCommand 'resume', { djOnly: true }, ({ player })=>
      player.play()

    # Now Playing (np)
    @registerCommand 'np', {
      aliases: ['nowplaying', 'n'], ignoreFreeze: true
    }, ({ msg, s, l, player })=>
      return l.player.notPlaying unless player.queue._d.nowPlaying
      m = await msg.channel.send(
        l.gen(l.player.hud.nowPlaying, player.queue.nowPlaying.voiceChannel.name),
        embed: await @hud.nowPlayingEmbed(player.queue.nowPlaying, l)
      )
      if s.autoDel then try
        msg.delete()
        await delay(15000)
        m.delete()

    # View Queue
    @registerCommand 'queue', { aliases: ['q'], ignoreFreeze: true }, ({ msg, a, s, l, p })=>
      return l.player.notPlaying unless p.queue._d.nowPlaying
      m = await msg.channel.send await @hud.nowPlaying(p.queue.nowPlaying, l),
                                       embed: @hud.queue(p.queue, parseInt(a) or 1, l, s)
      if s.autoDel then try
        msg.delete()
        await delay(30000)
        m.delete()

    # Shuffle
    @registerCommand 'shuffle', { djOnly: true }, ({ msg, a, l, player })=>
      return msg.channel.send l.player.queueEmpty unless player.queue._d.items.length
      player.queue.shuffle()
      msg.channel.send '✅'

    # Sauce
    @registerCommand 'sauce', {
      aliases: ['source', 'src'], ignoreFreeze: true
    }, ({ msg, args, s, l, player })=>
      return l.player.notPlaying unless player.queue._d.nowPlaying
      unless player.queue._d.nowPlaying.sauce
        return msg.reply l.player.noSauce
      m = await msg.reply l.gen(l.player.sauce, player.queue._d.nowPlaying.sauce)
      await delay(15000)
      try m.delete() if s.autoDel

    # Remove Last / Undo
    @registerCommand 'removelast', { aliases: ['undo', 'rl'] }, ({ msg, l, player })=>
      return msg.channel.send l.player.queueEmpty unless player.queue._d.items.length
      commands.run('remove', msg, [player.queue._d.items.length])

    # Remove
    @registerCommand 'remove', { aliases: ['rm'], argSeparator: '-' },
    ({ msg, args, l, player })=>
      index = (parseInt args[0]) - 1
      # Check if the item exists
      itm = player.queue._d.items[index]
      unless itm
        return msg.channel.send l.player.noSuchItem
      # Delete multiple items
      if args[1]
        # Check permissions
        return msg.reply l.admin.invalidLevel unless @permissions.isDJ msg.member
        # Calculate number of items to be deleted
        n = (parseInt args[1]) - (parseInt args[0]) + 1
        return msg.reply l.generic.invalidArgs if n < 1 or not player.queue._d.items[n-1]
        # Delet them
        player.queue.multiRemove(index, n, msg.member)
        msg.reply l.gen(l.player.multiRemove, n)
      else
        # Delete single item
        unless itm.requestedBy.id is msg.author.id or @permissions.isDJ msg.member
          return msg.channel.send l.player.onlyRemoveOwn
        { item } = player.queue.remove(index, msg.member)
        msg.channel.sendMessage l.player.hud.removed,
                                embed: @hud.removeItem(item, msg.member, l)

    # Swap
    @registerCommand 'swap', {
      aliases: ['sp'], djOnly: true, argSeparator: ' '
    }, ({ msg, args, l, player })=>
      return msg.channel.send l.generic.invalidArgs unless args.length is 2
      result = player.queue.swap(parseInt(args[0])-1, parseInt(args[1])-1, msg.member)
      return msg.reply l.generic.error unless result
      msg.channel.send @hud.swapItems msg.member, result.items,
                                      [result.index1, result.index2], l

    # Move
    @registerCommand 'move', {
      aliases: ['mv'], djOnly: true, argSeparator: ' '
    }, ({ msg, args, l, player })=>
      return msg.channel.send l.generic.invalidArgs unless args.length is 2
      result = player.queue.move(parseInt(args[0])-1, parseInt(args[1])-1, msg.member)
      return msg.reply l.generic.error unless result
      msg.channel.send @hud.moveItem msg.member, result.item,
                                     [result.index, result.position], l

    # Move to first place
    @registerCommand 'bump', { djOnly: true }, ({ msg, args, l, player })=>
      return msg.channel.send l.generic.invalidArgs unless parseInt(args) > 0
      result = player.queue.bump(parseInt(args)-1, msg.member)
      return msg.reply l.generic.error unless result
      msg.channel.send @hud.moveItem msg.member, result.item,
                       [result.index, result.position], l

    # Seek
    @registerCommand 'seek', { aliases: ['s'], djOnly: true }, ({ msg, args, player })=>
      try await player.seek(parseTime(args))
      catch e
        msg.reply e.message if e.message

    # Update Filters
    @registerCommand 'fx', { aliases: ['|'] }, ({ msg, args, l, player })=>
      return unless @permissions.isDJ(msg.author, msg.guild) or
                    msg.author.id is player.queue._d.nowPlaying.requestedBy
      try
        filters = @util.parseFilters(args, msg.member, true)
        await player.updateFilters(filters)
      catch e
        return msg.reply 'Something went wrong', embed: {
          description: e.message or e,
          color: 0xFF0000
        }

    # Change Volume
    @registerCommand 'volume', { aliases: ['vol'] }, ({ m, args, s, l, player })=>
      # No arguments = Display Volume
      unless args
        r = l.gen(l.player.hud.currantVolume, player.volume*100)
        if player.queue.nowPlaying
          r += "\n#{@hud.generateProgressOuter(player.queue.nowPlaying)}"
        mr = await m.reply r
        await delay(5000)
        try mr.delete() if s.autoDel
        return
      # Args = Change Volume
      return m.reply l.player.noVolumeChange unless @permissions.isDJ(m.member)
      return m.reply l.config.invalidValue if parseInt(args) > 100 or
             parseInt(args) < 0 or !isFinite(args)
      try
        player.volume = parseInt(args) / 100
        await delay(100)
        r = l.gen(l.player.hud.volumeSet, m.member.displayName, player.volume*100)
        if player.queue.nowPlaying
          r += "\n#{@hud.generateProgressOuter(player.queue.nowPlaying)}"
        mr = await m.reply r
        await delay(5000)
        try mr.delete() if s.autoDel
        return
      catch e
        m.reply e.message if e.message

    # Freeze / Unfreeze
    @registerCommand 'freeze', {
      djOnly: true, aliases: ['lock'], ignoreFreeze: true
    }, ({ msg, l, player })=>
      return 'Already frozen' if player.queue.frozen
      player.queue.frozen = true
      msg.reply l.player.queueFrozen

    @registerCommand 'unfreeze', {
      djOnly: true, aliases: ['unlock', 'thaw'], ignoreFreeze: true
    }, ({ msg, l, player })=>
      return 'Not frozen' unless player.queue.frozen
      player.queue.frozen = false
      msg.reply l.player.queueUnfrozen
    
    @registerCommand 'cancel', ({ msg, player })=>
      return unless player.pendingPlaylist? and
                    player.pendingPlaylist.by.id is msg.member.id or
                    @permissions.isDJ player.pendingPlaylist.by
      player.pendingPlaylist.pl.cancelled = true
      player.pendingPlaylist.pl.cancel()
      delete player.pendingPlaylist

  registerCommand: -> @playerModule.registerCommand.apply(@playerModule, arguments)

module.exports = PlayerCommands

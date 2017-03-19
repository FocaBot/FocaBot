reload = require('require-reload')(require)
EventEmitter = require 'events'
PlayerHud = reload './hud'
PlayerUtil = reload './util'
PlayerCommands = reload './commands'
AudioFilters = reload './filters'
GuildPlayer = reload './models/guildPlayer'

class PlayerModule extends BotModule
  init: =>
    @_guilds = {}
    @filters = AudioFilters
    @events = new EventEmitter
    @hud = new PlayerHud @
    @util = new PlayerUtil @
    @cmd = new PlayerCommands @
    Core.data.subscribe('GuildQueueFeed')
    Core.data.on('message', @_messageHandler)
    Core.bot.Dispatcher.on 'VOICE_CHANNEL_JOIN', @_handleVoiceJoin
    Core.bot.Dispatcher.on 'VOICE_CHANNEL_LEAVE', @_handleVoiceLeave

  getForGuild: (guild)=>
    return @_guilds[guild.id] if @_guilds[guild.id]?
    # Get guild data
    gData = await Core.guilds.getGuild(guild)
    # Create a new player object
    player = new GuildPlayer guild, gData, await Core.data.get("GuildQueue:#{guild.id}") or {
      # "empty" queue
      nowPlaying: undefined
      frozen: false
      items: []
    }
    @_guilds[guild.id] = player
    @events.emit('newPlayer', player)
    # Relay all events
    player.on 'playing', (item)=> @events.emit('playing', player, item)
    player.on 'paused', (item)=> @events.emit('paused', player, item)
    player.on 'suspended', (item)=> @events.emit('suspended', player, item)
    player.on 'seek', (item, time)=> @events.emit('seek', player, item, time)
    player.on 'filtersUpdated', (item)=> @events.emit('filtersUpdated', player, item)
    player.on 'start', (item)=> @events.emit('start', player, item)
    player.on 'end', (item)=> @events.emit('end', player, item)
    player.on 'stopped', => @events.emit('stopped', player)
    player.queue.on 'newItem', (data)=> @events.emit('newQueueItem', player, player.queue, data)
    player.queue.on 'removed', (data)=> @events.emit('queueRemoved', player, player.queue, data)
    player.queue.on 'swapped', (data)=> @events.emit('queueSwapped', player, player.queue, data)
    player.queue.on 'moved', (data)=> @events.emit('queueMoved', player, player.queue, data)
    player.queue.on 'shuffled', => @events.emit('queueShuffled', player, player.queue)
    player.queue.on 'cleared', => @events.emit('queueCleared', player, player.queue)
    player.queue.on 'updated', => @events.emit('queueUpdated', player, player.queue)
    # Save data on each update
    player.queue.on 'updated', =>
      await Core.data.set("GuildQueue:#{guild.id}", player.queue._d)
      # Notify other instances when the queue gets updated
      Core.data.publish('GuildQueueFeed', {
        type: 'queueUpdated'
        guild: guild.id
        by: Core.settings.shardIndex or 0
      })
    player

  registerCommand: (name, options, handler)=>
    if typeof options is 'function'
      handler = options
      options = {}
    super name, options, (msg, args, data, bot, core)=>
      player = await @getForGuild(msg.guild)
      # Frozen Queue = No Music Commands
      if player.queue.frozen and not options.ignoreFreeze
        return msg.reply """
        The queue is currently frozen. It is in read-only mode until a DJ or \
        Bot Commander unfreezes it with `#{Core.settings.prefix}unfreeze`
        """
      handler(msg, args, data, player, bot, core)

  _messageHandler: (channel, message)=>
    return unless channel is 'GuildQueueFeed' and message.type
    switch message.type
      # Queue updated outside current instance
      # This will be used in the future for web-based queue management :D
      when 'queueUpdated'
        return unless message.guild and message.by
        return unless message.by isnt (Core.settings.shardIndex or 0)
        return unless @_guilds[message.guild]
        newData = await Core.data.get("GuildQueue:#{guild.id}")
        # Safety Check
        return unless newData.items
        @_guilds[message.guild].queue._d = newData

  _handleVoiceJoin: (e)=>
    return unless @_guilds[e.guildId]
    player = @_guilds[e.guildId]
    return unless player.queue._d.nowPlaying and
           e.channelId is player.queue._d.nowPlaying.voiceChannel
    # Resume playback if suspended
    if e.channel.members.length > 1 and player.queue._d.nowPlaying.status is 'suspended'
      player.play()

  _handleVoiceLeave: (e)=>
    return unless @_guilds[e.guildId]
    player = @_guilds[e.guildId]
    return unless player.queue._d.nowPlaying and
           e.channelId is player.queue._d.nowPlaying.voiceChannel
    # Voice channel deleted
    return player.skip() unless e.channel
    # Bot moved from channel
    if e.user.id is Core.bot.User.id
      return player.skip() if not e.newChannelId
      player.queue.nowPlaying._d.voiceChannel = e.newChannelId
      player.queue.emit('updated')
    # No members left on voice channel
    if player.queue.nowPlaying.voiceChannel.members.length <= 1
      player.suspend()

  unload: =>
    # Remove ALL event listeners
    Object.keys(@_guilds).forEach (g)=>
      @_guilds[g].removeAllListeners()
      @_guilds[g].queue.removeAllListeners()
    @events.removeAllListeners()
    Core.data.removeListener('message', @_messageHandler)
    Core.bot.Dispatcher.removeListener('VOICE_CHANNEL_JOIN', @_handleVoiceJoin)
    Core.bot.Dispatcher.removeListener('VOICE_CHANNEL_LEAVE', @_handleVoiceLeave)

module.exports = PlayerModule

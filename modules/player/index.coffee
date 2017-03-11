reload = require('require-reload')(require)
EventEmitter = require 'events'
AudioHud = reload './hud'
AudioFilters = reload './filters'
GuildPlayer = reload './models/guildPlayer'

class PlayerModule extends BotModule
  init: =>
    @_guilds = {}
    @hud = new AudioHud @
    @filters = AudioFilters
    @events = new EventEmitter
    Core.data.subscribe('GuildQueueFeed')
    Core.data.on('message', @_messageHandler)
    Core.bot.Dispatcher.on 'VOICE_CHANNEL_JOIN', @_handleVoiceJoin
    Core.bot.Dispatcher.on 'VOICE_CHANNEL_LEAVE', @_handleVoiceLeave

  getForGuild: (guild)=>
    return @_guilds[guild.id] if @_guilds[guild.id]??
    # Create a new player object
    player = new GuildPlayer @, await Core.data.get("GuildQueue:#{guild.id}") or {
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
    player.on 'end', (item)=> @events.emit('end', player, item)
    player.on 'stopped', => @events.emit('stopped', player)
    player.queue.on 'newItem', (item)=> @events.emit('newQueueItem', player, player.queue, item)
    player.queue.on 'removed', (item)=> @events.emit('queueRemoved', player, player.queue, item)
    player.queue.on 'swapped', (data)=> @events.emit('queueSwapped', player, player.queue, data)
    player.queue.on 'moved', (data)=> @events.emit('queueMoved', player, player.queue, data)
    player.queue.on 'shuffled', => @events.emit('queueShuffled', player, player.queue)
    player.queue.on 'cleared', => @events.emit('queueCleared', player, player.queue)
    player.queue.on 'updated', => @events.emit('queueUpdated', player, player.queue)
    player.queue.on 'updated', =>
      # Save data
      await Core.data.set("GuildQueue:#{guild.id}", player.queue._d)
      # Notify other instances when the queue gets updated
      Core.data.publish('GuildQueueFeed', {
        type: 'queueUpdated'
        guild: guild.id
        by: Core.settings.shardIndex or 0
      })

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
    return unless player.queue.nowPlaying and
           e.channelId is player.queue._d.nowPlaying.voiceChannel.id
    # Resume playback if suspended
    if e.channel.members.length > 1 and player.queue.nowPlaying.status is 'suspended'
      player.resume()

  _handleVoiceLeave: (e)=>
    return unless @_guilds[e.guildId]
    player = @_guilds[e.guildId]
    return unless player.queue.nowPlaying and
           e.channelId is player.queue._d.nowPlaying.voiceChannel.id
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

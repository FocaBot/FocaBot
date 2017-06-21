reload = require('require-reload')(require)
PlayerHud = reload './hud'
PlayerUtil = reload './util'
PlayerCommands = reload './commands'
AudioFilters = reload './filters'
GuildPlayer = reload './models/guildPlayer'

class PlayerModule extends BotModule
  init: ->
    @_guilds = {}
    @filters = AudioFilters
    @e = Core.events
    @util = PlayerUtil
    @hud = new PlayerHud @
    @util.hud = @hud
    @cmd = new PlayerCommands @
    Core.data.subscribe('GuildQueueFeed')
    Core.data.on('message', @_messageHandler)

    # Setting parameters
    @registerParameter 'voteSkip', { type: Boolean, def: true }
    @registerParameter 'maxSongLength', { type: Number, def: 1800, min: 60, max: 21600 }
    @registerParameter 'maxItems', { type: Number, def: 0 }

  getForGuild: (guild)->
    return @_guilds[guild.id] if @_guilds[guild.id]?
    # Get guild data
    gData = await Core.guilds.getGuild(guild)
    # Create a new player object
    player = new GuildPlayer guild, gData, await Core.data.get("GuildQueue:#{guild.id}") or {
      # "empty" queue
      nowPlaying: undefined
      frozen: false
      volume: 1
      items: []
    }
    @_guilds[guild.id] = player
    @e.emit('newPlayer', player)
    # Relay all events
    player.on 'playing', (item)=> @e.emit('player.playing', player, item)
    player.on 'paused', (item)=> @e.emit('player.paused', player, item)
    player.on 'suspended', (item)=> @e.emit('player.suspended', player, item)
    player.on 'seek', (item, time)=> @e.emit('player.seek', player, item, time)
    player.on 'filtersUpdated', (item)=> @e.emit('player.filtersUpdated', player, item)
    player.on 'start', (item)=> @e.emit('player.start', player, item)
    player.on 'end', (item)=> @e.emit('player.end', player, item)
    player.on 'stopped', => @e.emit('player.stopped', player)
    player.queue.on 'newItem', (data)=> @e.emit('player.newQueueItem',
                                                     player, player.queue, data)
    player.queue.on 'removed', (data)=> @e.emit('player.queueRemoved',
                                                     player, player.queue, data)
    player.queue.on 'swapped', (data)=> @e.emit('player.queueSwapped',
                                                     player, player.queue, data)
    player.queue.on 'moved', (data)=> @e.emit('player.queueMoved',
                                                   player, player.queue, data)
    player.queue.on 'shuffled', => @e.emit('player.queueShuffled', player, player.queue)
    player.queue.on 'cleared', => @e.emit('player.queueCleared', player, player.queue)
    player.queue.on 'updated', => @e.emit('player.queueUpdated', player, player.queue)
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

  registerCommand: (name, options, handler)->
    if typeof options is 'function'
      handler = options
      options = {}
    super name, options, (params)=>
      { msg } = params
      player = await @getForGuild(msg.guild)
      # Frozen Queue = No Music Commands
      if player.queue.frozen and not options.ignoreFreeze
        return msg.reply """
        The queue is currently frozen. It is in read-only mode until a DJ or \
        Bot Commander unfreezes it with `#{Core.settings.prefix}unfreeze`
        """
      handler(Object.assign params, { player, p: player })

  _messageHandler: (channel, message)->
    return unless channel is 'GuildQueueFeed' and message.type
    switch message.type
      # Queue updated outside current instance
      when 'queueUpdated'
        return unless message.guild and message.by
        return unless message.by isnt (Core.settings.shardIndex or 0)
        return unless @_guilds[message.guild]
        newData = await Core.data.get("GuildQueue:#{guild.id}")
        # Safety Check
        return unless newData.items
        @_guilds[message.guild].queue._d = newData

  ready: ->
    @registerEvent 'discord.voiceStateUpdate', (oldMember, newMember)=>
      # User Joins a voice channel
      unless oldMember.voiceChannel
        player = @_guilds[newMember.guild.id]
        return unless player and player.queue._d.nowPlaying and
                      newMember.voiceChannel.id is player.queue._d.nowPlaying.voiceChannel.id
        # Resume playback if suspended
        if newMember.voiceChannel.members.length > 1 and
           player.queue._d.nowPlaying.status is 'suspended' then
           player.play()
      
      # User leaves or switches voice channels
      if not newMember.voiceChannel or newMember.voiceChannel isnt oldMember.voiceChannel
        player = @_guilds[newMember.guild.id]
        return unless player and player.queue._d.nowPlaying and
                      oldMember.voiceChannel.id is player.queue._d.nowPlaying.voiceChannel.id
        # Empty voice channel
        if player.queue.nowPlaying.voiceChannel.members.length <= 1
          player.suspend()

      # Bot Switches Voice Channels
      if newMember.id is Core.bot.user.id and oldMember.voiceChannel isnt newMember.voiceChannel
        player = @_guilds[newMember.guild.id]
        return player.skip() if player.queue._d.nowPlaying and not newMember.voiceChannel
        player.queue.nowPlaying._d.voiceChannel = newMember.voiceChannel.id
        player.queue.emit('updated')

  unload: ->
    # Remove ALL event listeners
    Object.keys(@_guilds).forEach (g)=>
      @_guilds[g].removeAllListeners()
      @_guilds[g].queue.removeAllListeners()
      Core.data.removeListener('message', @_messageHandler)

module.exports = PlayerModule

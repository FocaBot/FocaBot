reload = require('require-reload')(require)
PlayerHud = reload './hud'
PlayerUtil = reload './util'
PlayerCommands = reload './commands'
PlayerSearch = reload './search'
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
    @search = new PlayerSearch @
    @cmd = new PlayerCommands @

    # Setting parameters
    @registerParameter 'voiceChannel', { type: String, def: '*' }
    @registerParameter 'voteSkip', { type: Boolean, def: true }
    @registerParameter 'maxSongLength', { type: Number, def: 1800, min: 60, max: 21600 }
    @registerParameter 'maxItems', { type: Number, def: 0 }
    @registerParameter 'asyncPlaylists', { type: Boolean, def: false }
    @registerParameter 'inversePlaylist', { type: Boolean, def: false }
    @registerParameter 'unrestrictedLivestreams', { type: Boolean, def: false }

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

  ready: ->
    @registerEvent 'discord.voiceStateUpdate', (oldMember, newMember)=>
      # User Joins the same voice channel the bot's in
      if newMember and newMember.voiceChannel? and newMember.voiceChannel.connection?
        player = @_guilds[newMember.guild.id]
        return unless player and player.queue.nowPlaying
        # Resume playback if suspended
        if player.queue.nowPlaying.voiceChannel.members.size > 1 and
        player.queue.nowPlaying.status is 'suspended'
          player.play()
          # Remove timeout
          if player.timeout
            clearTimeout player.timeout
            delete player.timeout
      
      # User leaves the voice channel the bot's in
      if oldMember and oldMember.voiceChannel? and oldMember.voiceChannel.connection?
        player = @_guilds[oldMember.guild.id]
        return unless player and player.queue.nowPlaying
        # Empty voice channel
        if player.queue.nowPlaying.voiceChannel.members.size <= 1
          player.suspend()
          if not player.timeout
            # Inactivity timeout
            player.timeout = setTimeout ->
              player.stop()
            , 240 * 60 * 1000 # 4 hours

      # Bot Switches Voice Channels
      if newMember.id is Core.bot.user.id and newMember.voiceChannel?
        player = @_guilds[newMember.guild.id]
        return unless player and player.queue
        return player.skip() if player.queue.nowPlaying and not newMember.voiceChannel?
        return unless player.queue.nowPlaying and
                      player.queue.nowPlaying.voiceChannel.id isnt newMember.voiceChannel.id
        player.queue.nowPlaying.voiceChannel = newMember.voiceChannel
        player.queue.emit('updated')
        # Empty voice channel
        if player.queue.nowPlaying.voiceChannel.members.size <= 1
          player.suspend()
          if not player.timeout
            # Inactivity timeout
            player.timeout = setTimeout ->
              player.stop()
            , 240 * 60 * 1000 # 4 hours

  unload: ->
    # Remove ALL event listeners
    Object.keys(@_guilds).forEach (g)=>
      @_guilds[g].removeAllListeners()
      @_guilds[g].queue.removeAllListeners()

module.exports = PlayerModule

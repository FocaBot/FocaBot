GuildQueue = require './models/guildQueue'
QueueInstance = require './queueInstance'
{ delay } = Core.util

class AudioQueueManager
  constructor: (@playerModule)->
    @instances = {}
    { @hud } = @playerModule
    @initFeed()
    # Suspend playback when no users are on the voice channel
    Core.bot.Dispatcher.on 'VOICE_CHANNEL_LEAVE', (e)=>
      try
        queue = @instances[e.guildId] if @instances[e.guildId]?
        return if not queue or not queue.nowPlaying or e.channelId isnt queue.nowPlaying.voiceChannel.id
        return queue.nextItem() if not e.channel
        # Handle Voice Channel Changes
        if e.user.id is Core.bot.User.id
          return queue.nextItem() if not e.newChannelId
          queue.nowPlaying.voiceChannel = Core.bot.Channels.get(e.newChannelId)
          queue.emit('updated')
        if queue.nowPlaying.voiceChannel.members.length <= 1
          # No members left on voice channel.
          if queue.pause()
            queue.nowPlaying.status = 'suspended'
            queue.emit('updated')
    # Resume playback when a user re-joins
    Core.bot.Dispatcher.on 'VOICE_CHANNEL_JOIN', (e)=>
      try
        queue = @instances[e.guildId] if @instances[e.guildId]?
        return if not queue or not queue.nowPlaying or e.channelId isnt queue.nowPlaying.voiceChannel.id
        if e.channel.members.length > 1 and queue.nowPlaying.status is 'suspended'
          queue.nowPlaying.status = 'paused'
          try
            queue.resume()

  initFeed: =>
    @feed = await GuildQueue.changes()
    # Watch queue changes
    @feed.each (error, d)=>
      if error
        Core.log error, 2
        return
      if not d.isSaved() and @instances[d.guildId]
        delete @instances[d.guildId]
      else if @instances[d.guildId]?
        @instances[d.guildId].update(d) if d.updatedBy isnt (process.env.NODE_APP_INSTANCE or '0')

  getForGuild: (guild)=>
    return @instances[guild.id] if @instances[guild.id]?
    # Find for existing data on DB.
    q = await GuildQueue.filter({ guildId: guild.id }).run()
    if q[0]?
      qData = q[0]
    else
      qData = await new GuildQueue({ guildId: guild.id }).save()
    gData = await Core.guilds.getGuild(guild)
    instance = new QueueInstance(qData, gData)
    instance.on 'updated', =>
      serializeItems = (itm)=>
        return if not itm
        if itm.forEach
          arr = []
          itm.forEach (i)=> arr.push(serializeItems(i))
          arr
        else Object.assign({}, itm, {
          requestedBy: itm.requestedBy.id if itm.requestedBy
          voiceChannel: itm.voiceChannel.id if itm.voiceChannel
          textChannel: itm.textChannel.id if itm.textChannel
          duration: itm.duration or null
        })
      instance.data.merge({
        timestamp: new Date()
        updatedBy: process.env.NODE_APP_INSTANCE or '0'
        nowPlaying: serializeItems(instance.nowPlaying)
        items: serializeItems(instance.items)
      })
      instance.data.save()
      # Dynamic nickname
      return if not gData.data.dynamicNick
      currentNick = Core.bot.User.memberOf(guild).nick
      newNick = null
      if instance.nowPlaying
        title = instance.nowPlaying.title.substr(0, 28)
        title = title.substr(0, 25) + '...' if instance.nowPlaying.title.length > 28
        switch instance.nowPlaying.status
          when 'playing'
            newNick = "▶ | " + title
          when 'paused', 'suspended'
            newNick = "⏸ | " + title
      if currentNick isnt newNick
        Core.bot.User.memberOf(guild).setNickname(newNick)
    # Event Messages
    instance.on 'start', (item)=>
      try
        m = await item.textChannel.sendMessage "Now playing in `#{item.voiceChannel.name}`:",
                                        false,
                                        @hud.nowPlayingEmbed(instance, item)
        await delay(5000)
        m.delete() if instance.guildData.data.autoDel
    instance.on 'added', (item)=>
      return if item.playlist
      try item.textChannel.sendMessage 'Added to the queue:',
                                       false,
                                       @hud.addItem(item, instance)
    @instances[guild.id] = instance
    instance

module.exports = AudioQueueManager

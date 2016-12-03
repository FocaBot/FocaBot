GuildQueue = require './models/guildQueue'
QueueInstance = require './queueInstance'

class AudioQueueManager
  constructor: (@playerModule)->
    @instances = {}
    @initFeed()

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
        @instances[d.guildId].update(d)

  getForGuild: (guild)=>
    return Promise.resolve @instances[guild.id] if @instances[guild.id]?
    # Find for existing data on DB.
    q = await GuildQueue.filter({ guildId: guild.id }).run()
    if q[0]?
      qData = q[0]
    else
      qData = await new GuildQueue({ guildId: guild.id }).save()
    instance = new QueueInstance(qData, await Core.guilds.getGuild(guild))
    instance.on 'updated', =>
      serializeItems = (i)=>
        i.requestedBy = i.requestedBy.id if i.requestedBy
        i.voiceChannel = i.voiceChannel.id if i.voiceChannel
        i.textChannel = i.textChannel.id if i.textChannel
      instance.data.timestamp = new Date()
      instance.data.updatedBy = process.env.NODE_APP_INSTANCE or '0'
      instance.data.nowPlaying = instance.nowPlaying
      instance.data.items = instance.items
      serializeItems instance.data.nowPlaying if instance.data.nowPlaying
      serializeItems i for i in instance.data.items if instance.data.items
      instance.data.save()
    @instances[guild.id] = instance
    instance

module.exports = AudioQueueManager
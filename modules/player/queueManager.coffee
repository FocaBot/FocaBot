GuildQueue = require './models/guildQueue'
QueueInstance = require './queueInstance'

class AudioQueueManager
  constructor: (@playerModule)->
    @instances = {}
    { @hud } = @playerModule
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
    return @instances[guild.id] if @instances[guild.id]?
    # Find for existing data on DB.
    q = await GuildQueue.filter({ guildId: guild.id }).run()
    if q[0]?
      qData = q[0]
    else
      qData = await new GuildQueue({ guildId: guild.id }).save()
    instance = new QueueInstance(qData, await Core.guilds.getGuild(guild))
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
          duration: null if not isFinite(itm.duration)
        })
      instance.data.merge({
        timestamp: new Date()
        updatedBy: process.env.NODE_APP_INSTANCE or '0'
        nowPlaying: serializeItems(instance.nowPlaying)
        items: serializeItems(instance.items)
      })
      instance.data.save()
    instance.on 'playing', (item)=>
      try
        m = await item.textChannel.sendMessage @hud.nowPlaying(instance, item, true)
        await delay(5000)
        m.delete() if instance.guildData.data.autoDel
    @instances[guild.id] = instance
    instance

module.exports = AudioQueueManager
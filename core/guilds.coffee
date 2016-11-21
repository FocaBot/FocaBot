AudioPlayer = require './audioPlayer'
AudioQueue = require './audioQueue'
thinky = require './thinky'
type = thinky.type

Guild = thinky.createModel "Guild", {
  id: type.string()
  discordId: type.string()
  prefix: type.string()
  restricted: type.boolean().default(false)
  autoDel: type.boolean().default(true)
  allowNSFW: type.boolean().default(false)
  voteSkip: type.boolean().default(true)
  allowWaifus: type.boolean().default(true)
}

# Additional data about servers
class BotGuildManager
  constructor: (@engine)->
    @guilds = {}
    # Suscribe to guild changes
    Guild.changes().then (feed)=>
      feed.each (error, doc)=>
        if error
          console.error error
          return
        # delet
        if not doc.isSaved()
          delete @guilds[doc.discordId]
        # edi
        else if @guilds[doc.discordId]?
          @guilds[doc.discordId].data = doc

  getGuild: (guild)=> new Promise (resolve, reject)=>
    if not guild
      # dummy "guild" data for DMs
      return resolve {
        data: {
          prefix: @engine.prefix
          autoDel: true
          restricted: false
          allowNSFW: true
          voteSkip: false
          allowWaifus: true
        }
      }
    return resolve @guilds[guild.id] if @guilds[guild.id]
    Guild.filter({ discordId: guild.id }).run()
    # Find Guild in the DB
    .then (guilds)=>
      return Promise.resolve guilds[0] if guilds[0]
      # Create one if not present
      new Guild({
        discordId: guild.id
      }).save()
    .then (data)=>
      g = { data }
      @guilds[guild.id] = g
      @initializeGuild g, guild
      resolve g

  initializeGuild: (g, guild)=>
    g.audioPlayer = new AudioPlayer @engine, guild, g
    g.queue = new AudioQueue @engine, guild, g
    g


module.exports = BotGuildManager

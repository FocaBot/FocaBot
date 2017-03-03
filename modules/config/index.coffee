# Configuration Manager
# Must be loaded before all standard modules.
# Requires the DB module to be loaded first.
{ type } = Core.db
Commands = require './commands'

# DB Model
Guild = Core.db.createModel 'Guild', {
  id: type.string()
  discordId: type.string()
  prefix: type.string()
  autoDel: type.boolean().default(true)
  allowNSFW: type.boolean().default(false)
  voteSkip: type.boolean().default(true)
  restrict: type.boolean().default(false)
  allowWaifus: type.boolean().default(true)
  allowTags: type.boolean().default(true)
  greet: type.string().default('off')
  farewell: type.string().default('off')
  maxSongLength: type.number().default(1800) # 30 minutes
  dynamicNick: type.boolean().default(false)
}

class ConfigModule extends BotModule
  init: =>
    # Reset guild cache
    Core.guilds._guilds = {}
    # Override the default guild initialization function
    Object.getPrototypeOf(Core.guilds).getGuild = (guild)->
      # Dummy guild data for DMs
      return Promise.resolve {
        data: {
          prefix: Core.prefix
          autoDel: true
          restricted: false
          allowNSFW: true
          voteSkip: false
          allowTags: true
          restrict: false
          allowWaifus: true
        }
      } if not guild
      return Promise.resolve @_guilds[guild.id] if @_guilds[guild.id]
      # Find Guild in the DB
      guilds = await Guild.filter({ discordId: guild.id }).run()
      if guilds[0]
        data = guilds[0]
      # Create one if not present
      else
        data = await new Guild({
          discordId: guild.id
        }).save()
      g = { data }
      @_guilds[guild.id] = g
      @initializeGuild g, guild
      Promise.resolve g

    # Suscribe to guild updates
    Guild.changes().then (feed)=>
      feed.each (error, doc)=>
        if error
          Core.log error, 2
          return
        # delet
        if not doc.isSaved()
          delete Core.guilds._guilds[doc.discordId]
        # edi
        else if Core.guilds._guilds[doc.discordId]?
          Core.guilds._guilds[doc.discordId].data = doc

    # Custom Prefixes
    Object.getPrototypeOf(Core.commands).getPrefix = (msg)->
      if msg.content.indexOf(Core.settings.prefix) is 0
        return Promise.resolve Core.settings.prefix
      d = await Core.guilds.getGuild(msg.guild)
      Promise.resolve d.data.prefix or Core.settings.prefix

    # Yes, we're actually overriding the FocaBotCore command handler.
    origCommandHandler = Object.getPrototypeOf(Core.commands).processMessage

    Object.getPrototypeOf(Core.commands).processMessage = (msg)->
      try
        d = await Core.guilds.getGuild(msg.guild)
        return if d.data.restrict and not Core.permissions.isDJ msg.member
        origCommandHandler.call(@, msg)
      catch e
        Core.log e,2

    @commands = new Commands @

module.exports = ConfigModule

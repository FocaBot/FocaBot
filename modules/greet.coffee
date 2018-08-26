Discord = require 'discord.js'

class GreetModule extends BotModule
  init: ->
    @registerParameter 'greetChannel', { type: Discord.TextChannel }
    @registerParameter 'greet', { type: String, min: 1, def: 'off' }
    @registerParameter 'farewell', { type: String, min: 1, def: 'off' }
    
    @registerEvent 'discord.guildMemberAdd', (member)=>
      s = await Core.settings.getForGuild(member.guild)
      if s.greet and s.greet isnt 'off'
        c = @getDefaultChannel(member.guild, s)
        c.send(
          s.greet
          .replace /\{mention\}/g, member.toString()
          .replace /\{name\}/g, member.displayName
          .replace /\{server\}/g, member.guild.name
        )

    @registerEvent 'discord.guildMemberRemove', (member)=>
      s = await Core.settings.getForGuild(member.guild)
      if s.farewell and s.farewell isnt 'off'
        c = @getDefaultChannel(member.guild, s)
        c.send(
          s.farewell
          .replace /\{mention\}/g, member.toString()
          .replace /\{name\}/g, member.displayName
          .replace /\{server\}/g, member.guild.name
        )

  getDefaultChannel: (guild, s)->
    if s.greetChannel
      c = guild.channels.get(s.greetChannel)
      return c if c
    if guild.defaultChannel
      guild.defaultChannel
    else
      guild.channels.find((c)-> c.type is 'text') 

module.exports = GreetModule

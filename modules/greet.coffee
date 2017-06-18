class GreetModule extends BotModule
  init: ->
    @registerEvent 'discord.guildMemberAdd', (member)=>
      s = await Core.settings.getForGuild(member.guild)
      if s.greet and s.greet isnt 'off'
        member.guild.defaultChannel.send(
          s.greet
          .replace /\{mention\}/g, member.toString()
          .replace /\{name\}/g, member.displayName
          .replace /\{server\}/g, member.guild.name
        )

    @registerEvent 'discord.guildMemberRemove', (member)=>
      s = await Core.settings.getForGuild(member.guild)
      if s.farewell and s.farewell isnt 'off'
        member.guild.defaultChannel.send(
          s.farewell
          .replace /\{mention\}/g, member.toString()
          .replace /\{name\}/g, member.displayName
          .replace /\{server\}/g, member.guild.name
        )

module.exports = GreetModule

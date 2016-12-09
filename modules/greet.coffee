class GreetModule extends BotModule
  init:=>
    { Dispatcher } = @engine.bot

    Dispatcher.on 'GUILD_MEMBER_ADD', (e)=>
      { data } = await Core.guilds.getGuild e.guild
      if data.greet and data.greet isnt 'off'
        e.guild.generalChannel.sendMessage(
          data.greet
          .replace /\{mention\}/g, e.member.mention
          .replace /\{name\}/g, e.member.username
          .replace /\{server\}/g, e.guild.name
        )

    Dispatcher.on 'GUILD_MEMBER_REMOVE', (e)=>
      { data } = await Core.guilds.getGuild e.guild
      if data.farewell and data.farewell isnt 'off'
        e.guild.generalChannel.sendMessage(
          data.farewell
          .replace /\{mention\}/g, e.user.mention
          .replace /\{name\}/g, e.user.username
          .replace /\{server\}/g, e.guild.name
        )

module.exports = GreetModule

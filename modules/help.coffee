class HelpModule extends BotModule
  init: =>
    {@prefix} = @engine
    @registerCommand 'help', { allowDM: true }, @helpCommandFunction
    @registerCommand 'filters', { allowDM: true }, @filtersCommandFunction

  helpCommandFunction: (msg, args, d)=>
    pfx = d.data.prefix or @prefix
    gstr = ""
    if msg.guild
      gstr = "\nPrefix for \`#{msg.guild.name}\`: #{pfx}"
    reply = """
    **#{@engine.name} #{@engine.version}**
    Made by @TheBITLINK#3141

    #{gstr}
    
    This bot is not yet public, though you can send me a DM if you want it on your server.

    Changelog: https://thebitlink.gitbooks.io/focabot-docs/content/Changelog.html
    Command List: https://thebitlink.gitbooks.io/focabot-docs/content/Commands.html
    Audio Filters: https://thebitlink.gitbooks.io/focabot-docs/content/Filters.html
    Configuration: https://thebitlink.gitbooks.io/focabot-docs/content/Configuration.html
    """
    msg.author.openDM().then (dm)=>
      dm.sendMessage reply
      msg.reply 'Check your DMs!' if msg.channel.guild_id
    

  filtersCommandFunction: (msg,args)=>
    msg.reply 'To learn more about audio filters, check this link: https://thebitlink.gitbooks.io/focabot-docs/content/Filters.html'

module.exports = HelpModule

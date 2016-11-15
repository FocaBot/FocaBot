class HelpModule extends BotModule
  init: =>
    {@prefix, @getGuildData} = @engine
    @registerCommand 'help', { allowDM: true }, @helpCommandFunction
    @registerCommand 'filters', { allowDM: true }, @filtersCommandFunction

  helpCommandFunction: (msg, args)=> @getGuildData(msg.guild).then (d)=>
    pfx = d.data.prefix or @prefix
    gstr = ""
    if msg.guild
      gstr = "\nPrefix for `#{msg.guild.name}`: #{pfx}"
    reply = """
    **#{@engine.name} #{@engine.version} (#{@engine.versionName})**
    Made by @TheBITLINK#3141

    #{gstr}
    
    This bot is not yet public, though you can send me a DM if you want it on your server.

    Changelog: https://gist.github.com/TheBITLINK/61f86a841f7d6fed896363d67ddd4d40

    Command List: https://thebitlink.gitbooks.io/focabot-docs/content/Commands.html
    Audio Filters: https://thebitlink.gitbooks.io/focabot-docs/content/Filters.html
    Configuration: https://thebitlink.gitbooks.io/focabot-docs/content/Configuration.html
    ```
    """
    msg.author.openDM().then (dm)=>
      dm.sendMessage reply
      msg.reply 'Check your DMs!' if msg.channel.guild_id
    

  filtersCommandFunction: (msg,args)=> @getGuildData(msg.guild).then (d)=>
    msg.reply 'To learn more about audio filters, check this link: https://thebitlink.gitbooks.io/focabot-docs/content/Filters.html'

module.exports = HelpModule

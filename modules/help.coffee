class HelpModule extends BotModule
  init: =>
    {@prefix} = @engine
    @registerCommand 'help', { allowDM: true }, @helpCommandFunction
    @registerCommand 'filters', { allowDM: true }, @filtersCommandFunction

  helpCommandFunction: (msg, args, d)=>
    pfx = d.data.prefix or @prefix
    gstr = ""
    if msg.guild
      gstr = "\nPrefix for `#{msg.guild.name}`: #{pfx}"
    reply = """
    **#{@engine.settings.name} #{@engine.settings.version}**
    Running FocaBotCore #{@engine.version}
    #{gstr}
    
    #{process.env.HELP_MESSAGE or ''}

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

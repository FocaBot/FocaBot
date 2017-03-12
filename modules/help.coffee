class HelpModule extends BotModule
  init: =>
    { @prefix } = @engine
    @registerCommand 'help', { allowDM: true }, @helpCommandFunction
    @registerCommand 'filters', { allowDM: true }, @filtersCommandFunction

  helpCommandFunction: (msg, args, d)=>
    pfx = d.data.prefix or @prefix
    gstr = ''
    if msg.guild
      gstr = "\n**Prefix for #{msg.guild.name}**: `#{pfx}`\n"
    msg.channel.sendMessage '', false, {
      url: 'https://focabot.thebit.link/'
      color: if Core.settings.debug then 0xFF3300 else 0x00AAFF
      author: {
        name: "#{@engine.settings.name} #{@engine.settings.version}"
        icon_url: Core.bot.User.avatarURL
      }
      description: """
      #{gstr}#{process.env.HELP_MESSAGE or ''}
      """
      fields: [
        {
          name: 'Help Links:',
          value: """
          [Commands](https://focabot.thebit.link/commands?prefix=#{encodeURIComponent pfx}) / \
          [Filters](https://focabot.thebit.link/filters?prefix=#{encodeURIComponent pfx}) / \
          [Manual](https://focabot.thebit.link/manual) / \
          [Donate](https://tblnk.me/focabot-donate) / \
          [GitHub](https://github.com/FocaBot)
          """
        }
      ]
      footer:
        icon_url: 'https://www.gravatar.com/avatar/93f31b88845bcdca6bcfa908ebeef4ab'
        text: 'Made by TheBITLINK#3141'
    }

  filtersCommandFunction: (msg,args)=>
    pfx = d.data.prefix or @prefix
    msg.reply """
    To learn more about audio filters, check this link: \
    https://focabot.thebit.link/filters?prefix=#{encodeURIComponent pfx}
    """

module.exports = HelpModule

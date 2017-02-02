class HelpModule extends BotModule
  init: =>
    {@prefix} = @engine
    @registerCommand 'help', { allowDM: true }, @helpCommandFunction
    @registerCommand 'filters', { allowDM: true }, @filtersCommandFunction

  helpCommandFunction: (msg, args, d)=>
    pfx = d.data.prefix or @prefix
    gstr = ""
    if msg.guild
      gstr = "\n**Prefix for #{msg.guild.name}**: `#{pfx}`\n"
    msg.channel.sendMessage '', false, {
      url: 'https://focabot.thebit.link/'
      color: 0x00AAFF if not Core.settings.debug
      color: 0xFF3300 if Core.settings.debug
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
          value: "[Commands](https://focabot.thebit.link/commands?prefix=#{encodeURIComponent pfx}) / " +
          "[Filters](https://focabot.thebit.link/filters?prefix=#{encodeURIComponent pfx}) / " +
          "[Manual](https://focabot.thebit.link/manual) / " +
          "[GitHub](https://github.com/FocaBot)"
        }
      ]
      footer:
        icon_url: "https://cdn.discordapp.com/avatars/164588804362076160/a_fb8ec7f2fefd17b5759a403e18f27929.jpg"
        text: "Made by TheBITLINK#3141"
    }
    # msg.author.openDM().then (dm)=>
    #   dm.sendMessage reply
    #   msg.reply 'Check your DMs!' if msg.channel.guild_id

  filtersCommandFunction: (msg,args)=>
    msg.reply 'To learn more about audio filters, check this link: https://focabot.thebit.link/filters?prefix=#{encodeURIComponent pfx}'

module.exports = HelpModule

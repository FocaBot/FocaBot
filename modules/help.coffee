QS = require('querystring')

class HelpModule extends BotModule
  init: ->
    @registerCommand 'help', { allowDM: true }, ({ msg, args, s, l })=>
      gstr = ''
      if msg.guild
        gstr = "\n**#{l.gen l.help.prefix, msg.guild.name}** `#{s.prefix}`\n"
        # Calculate permission level
        level = 0
        level = 1 if Core.permissions.isDJ(msg.member)
        level = 2 if Core.permissions.isAdmin(msg.member)
        level = 3 if Core.permissions.isOwner(msg.member)
        qs = QS.stringify {
          prefix: s.prefix
          lang: s.locale
          level
        }

      msg.channel.send '', embed: {
        url: 'https://www.focabot.xyz/'
        color: if Core.properties.debug then 0xFF3300 else 0x00AAFF
        author: {
          name: "#{Core.properties.name} #{Core.properties.version}"
          icon_url: Core.bot.user.displayAvatarURL
        }
        description: """
        #{gstr}#{process.env.HELP_MESSAGE or ''}
        """
        fields: [
          {
            name: l.help.links,
            value: """
            [#{l.help.commands}](https://www.focabot.xyz/commands?#{qs}) / \
            [#{l.help.filters}](https://www.focabot.xyz/filters?#{qs}) / \
            [#{l.help.manual}](https://www.focabot.xyz/docs?#{qs}) / \
            [#{l.help.donate}](https://www.focabot.xyz/donate?#{qs}) / \
            [GitHub](https://github.com/FocaBot)
            """
          }
        ]
        footer:
          icon_url: 'https://www.gravatar.com/avatar/93f31b88845bcdca6bcfa908ebeef4ab'
          text: 'Made by TheBITLINK#3141'
      }

module.exports = HelpModule

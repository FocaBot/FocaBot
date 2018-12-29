/**
 * Help module.
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 **/
import { Azarasi, CommandContext } from 'azarasi'
import { UserPermissions } from 'azarasi/lib/permissions'
import { registerCommand } from 'azarasi/lib/decorators'
import QS from 'querystring'


export default class Help extends Azarasi.Module {
  /**
   * Help command
   */
  @registerCommand({ allowDM: true })
  help ({ msg, s, l, perms } : CommandContext) {
    const guildHelp = msg.guild ? `\n**${l!.gen(l!.help.prefix, msg.guild.name)}** \`${s.prefix}\`\n\n` : ''
    const qs = msg.guild ? '?' + this.generateQuery(s.prefix, perms) : ''
    const props = this.az.properties

    msg.channel.send('', { embed: {
      url: 'https://www.focabot.xyz/',
      color: props.debug ? 0xFF3300 : 0x00AAFF,
      author: {
        name: `${props.name} ${props.version} (${props.versionName})`,
        icon_url: this.bot.user.displayAvatarURL
      },
      description: guildHelp + props.focaBot.misc.helpMessage,
      fields: [{
        name: l!.help.links,
        value: [
          `[${l!.help.commands}](https://www.focabot.xyz/commands${qs})`,
          `[${l!.help.filters}](https://www.focabot.xyz/filters${qs})`,
          `[${l!.help.manual}](https://www.focabot.xyz/docs${qs})`,
          `[${l!.help.donate}](https://www.focabot.xyz/donate${qs})`,
          `[GitHub](https://github.com/FocaBot)`
        ].join(' / ')
      }],
      footer: {
        icon_url: 'https://www.gravatar.com/avatar/93f31b88845bcdca6bcfa908ebeef4ab',
        text: 'FocaBot made by TheBITLINK#3141' // Please keep this on derivate works
      }
    }})
  }

  generateQuery (prefix : string | undefined, perms : UserPermissions) {
    let level = 0
    if (perms.isDJ) level = 1
    if (perms.isAdmin) level = 2
    if (perms.isOwner) level = 3
    return QS.stringify({ prefix, level })
  }
}

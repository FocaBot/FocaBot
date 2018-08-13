/**
 * Status module.
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 **/
import { Azarasi } from 'azarasi'

export default class Status extends Azarasi.Module {
  ready () {
    if (this.az.properties.debug) {
      this.bot.user.setPresence({
        status: 'dnd',
        game: {
          name: this.az.properties.version
        }
      })
    } else {
      this.bot.user.setPresence({
        status: 'online',
        game: {
          name: this.az.properties.prefix + 'help | focabot.xyz'
        }
      })
    }
  }
}

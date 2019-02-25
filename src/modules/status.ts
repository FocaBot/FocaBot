/**
 * Status module.
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 **/
import { Azarasi } from 'azarasi'

export default class Status extends Azarasi.Module {
  ready () {
    if (this.az.properties.debug) {
      this.client.user.setPresence({
        status: 'dnd',
        game: {
          name: this.az.properties.version
        }
      })
    } else {
      this.client.user.setPresence({
        status: 'online',
        game: {
          name: this.az.properties.prefix + 'help | focabot.xyz'
        }
      })
    }
  }
}


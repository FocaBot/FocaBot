/**
 * Inline commands module.
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 **/
import { Azarasi } from 'azarasi'

export default class InlineCommands extends Azarasi.Module {
  defaultDisabled = true
  init() {
    this.registerCommand(/{{(.+?)}}/, ({ msg, args }) => {
      // Maybe allow multiple commands in the future? (with some kind of hard limit)
      this.az.commands.processMessage(msg, args[1])
    })
  }
}

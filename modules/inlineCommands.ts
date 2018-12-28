/**
 * Inline commands module.
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 **/
import { Azarasi, CommandArgs } from 'azarasi'
import { registerCommand } from 'azarasi/lib/decorators'

export default class InlineCommands extends Azarasi.Module {
  defaultDisabled = true

  /**
   * Regex-triggered "command" that captures text within {{double braces}} and makes Azarasi process
   * it as a separate message, therefore triggering commands if one is present.
   */
  @registerCommand(/{{(.+?)}}/)
  handleInlineCommand ({ msg, args } : CommandArgs) {
    this.az.commands.processMessage(msg, args[1])
  }
}

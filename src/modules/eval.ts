/**
 * Eval module.
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 **/
import { Azarasi, CommandContext } from 'azarasi'
import { DMChannel, GroupDMChannel, TextChannel } from 'discord.js'
import { registerCommand } from 'azarasi/lib/decorators'
import { inspect } from 'util'
import axios from 'axios'
import VM from 'vm'

export default class Eval extends Azarasi.Module {
  globalNamespace = {}

  /**
   * Evaluates JavaScript code in the bot's context.
   * @param code
   */
  @registerCommand({ ownerOnly: true }) eval (ctx : CommandContext, code : string) {
    const { msg } = ctx
    // Enclose script in an async function to allow use of the "await" keyword.
    const script = `(async () => {\n${code}\n})()`
    const printFn = (input : any, depth = 1) => this.print(msg.channel, input, depth)
    const vmContext = VM.createContext({
      ...this.globalNamespace,
      ...ctx,
      Global: this.globalNamespace,
      print: printFn,
      p: printFn,
      axios
    })
    try {
      VM.runInContext(script, vmContext, {
        filename: 'eval',
        lineOffset: -1
      })
    } catch (e) {
      printFn(e)
    }
  }

  /**
   * Formats an input and sends it to a text channel.
   * @param channel - Channel to send the formatted output.
   * @param input - Object to format
   * @param depth - Maximum object depth
   */
  print (channel : TextChannel | DMChannel | GroupDMChannel, input : any, depth = 1) {
    if (typeof input === 'string') {
      channel.send(input)
    } else {
      channel.send('```js\n' + inspect(input, false, depth) + '```')
    }
  }
}


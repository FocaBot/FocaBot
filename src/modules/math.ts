/**
 * Math module.
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 **/
import { Azarasi, CommandContext } from 'azarasi'
import { registerCommand } from 'azarasi/lib/decorators'
import mathjs from 'mathjs'

export default class Math extends Azarasi.Module {
  /**
   * Performs math calculations using math.js
   */
  @registerCommand({ allowDM: true, aliases: ['calc', 'math'] })
  calculate ({ msg, args, l } : CommandContext) {
    const result = mathjs.eval(args)
    if (result == null) return msg.reply(l!.generic.invalidArgs)

    msg.channel.send(l!.gen('```js\n{1}\n```', args.toString()), {
      embed: {
        color: 0xDC3912,
        description: l!.gen('**{1}** {2}', l!.math.result, l!.transform(result))
      }
    })
  }
}


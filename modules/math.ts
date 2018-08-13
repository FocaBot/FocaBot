/**
 * Math module.
 * @author thebitlink
 * @license MIT
 **/
import { Azarasi } from 'azarasi'
import mathjs from 'mathjs'

export default class Math extends Azarasi.Module {
  init() {
    this.registerCommand('calculate', { allowDM: true, aliases: ['calc', 'math'] }, ({ msg, args, l }) => {
      const result = mathjs.eval(args)
      if (!result) return msg.reply(l!.generic.invalidArgs)

      msg.channel.send(l!.gen('```js\n{1}\n```', args.toString()), {
        embed: {
          color: 0xDC3912,
          description: l!.gen('**{1}** {2}', l!.math.result, l!.transform(result))
        }
      })
    })
  }
}

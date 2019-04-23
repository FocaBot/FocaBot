/**
 * Rng module.
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 **/
import { Azarasi, CommandContext } from 'azarasi'
import { registerCommand } from 'azarasi/lib/decorators'
import Chance from 'chance'

export default class RNG extends Azarasi.Module {
  chance = new Chance()

  /**
   * Roll a dice
   * @param dice - Dice to roll, in RPG format (2d6)
   */
  @registerCommand roll ({ msg, l } : CommandContext, dice : string) {
    let roll = dice
    if (!/\d+d\d+/.test(dice)) {
      // We're probably dealing with a non-rpg dice
      roll = parseInt(dice) ? `1d${dice}` : '1d100' // When in doubt, roll a single, 100-faces dice.
    }
    const result = this.chance.rpg(roll)
    let reply = l.gen(l.rng.roll, msg.member.toString(), result.join(', '))
    if (result.length > 1) {
      const total = result.reduce((a, b) => a + b)
      reply += `\n\n${l.gen(l.rng.total, total.toString())}`
    }
    msg.channel.send(reply)
  }

  /**
   * Choose an element from the items.
   * @param items - Set of items to choose from
   */
  @registerCommand({ argSeparator: ';', aliases: ['pick'] })
  choose ({ msg, l } : CommandContext, ...items : string[]) {
    if (items.length < 2) {
      msg.reply(l.rng.notEnoughItems)
    } else {
      msg.reply(l.gen(l.rng.choice, this.chance.pickone(items)))
    }
  }

  /**
   * 8ball command.
   */
  @registerCommand('8ball')
  eightBall ({ msg, l } : CommandContext) {
    msg.reply('🎱' + this.chance.pickone(l.rng['8ball']))
  }

  /**
   * Rate something in a 1-10 scale.
   * This isn't actually random, but fun to have anyways
   * @param target - Thing to rate
   */
  rate ({ msg, l } : CommandContext, target : string) {
    if (!target) return
    let hash = 0
    for (let i = 0; i < target.length; i++) {
      hash = ((hash << 5) - hash) + target.charCodeAt(i)
    }
    const rate = Math.ceil(((hash & 0xFF) / 0xFF) * 10)
    msg.reply(l.gen(l.rng.rate, target, rate.toString()))
  }
}


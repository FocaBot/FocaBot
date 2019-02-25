/**
 * Seal module.
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 **/
import { Azarasi, CommandContext } from 'azarasi'
import { registerCommand } from 'azarasi/lib/decorators'
import Chance from 'chance'

export default class Seal extends Azarasi.Module {
  chance = new Chance()

  /**
   * Sends random pictures of seals.
   */
  @registerCommand seal ({ msg } : CommandContext) {
    const seal = this.chance.integer({ min: 1, max: 83 }).toString().padStart(4, '0')
    msg.channel.send(`https://focabot.github.io/random-seal/seals/${seal}.jpg`)
  }

  /**
   * Praise the seal!
   */
  @registerCommand pray ({ msg } : CommandContext) {
    msg.channel.send({ embed: {
      image: {
        url: 'https://cdn.discordapp.com/attachments/248274146931245056/327639305172287488/praise_the_seal.jpg'
      }
    }})
  }
}


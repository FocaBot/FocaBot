/**
 * Poll module.
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 **/
import { Azarasi, CommandContext } from 'azarasi'
import { Message } from 'discord.js'
import { registerCommand } from 'azarasi/lib/decorators'

export default class Poll extends Azarasi.Module {
  answerSymbols = ['🇦','🇧', '🇨','🇩','🇪','🇫','🇬','🇭','🇮','🇯','🇰','🇱','🇲','🇳','🇴']

  /**
   * Starts a simple reaction-based poll.
   * @param question - Poll title
   * @param answers - Possible options
   */
  @registerCommand({ argSeparator: '|' })
  async poll ({ msg, l } : CommandContext, question : string, ...answers : string[]) {
    // Validate answer count
    if (answers.length > 15) return msg.reply(l!.poll.tooManyAnswers)
    if (answers.length < 2) return msg.reply(l!.poll.notEnoughAnswers)

    const embed = {
      color: 0xB1FF86,
      title: question,
      description: answers.map((answer, ix) => `${this.answerSymbols[ix]} - ${answer}`).join('\n')
    }

    const pollMsg = await msg.channel.send(l!.gen(l!.poll.pollStarted, msg.author.toString()), { embed }) as Message
    for (let i = 0; i < answers.length; i++) {
      await pollMsg.react(this.answerSymbols[i])
    }
  }
}

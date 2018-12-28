/**
 * Poll module.
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 **/
import { Azarasi, CommandArgs } from 'azarasi'
import { Message } from 'discord.js'
import { registerCommand } from 'azarasi/lib/decorators'

export default class Poll extends Azarasi.Module {
  answerSymbols = ['🇦','🇧', '🇨','🇩','🇪','🇫','🇬','🇭','🇮','🇯','🇰','🇱','🇲','🇳','🇴']

  /**
   * Starts a new poll.
   */
  @registerCommand({ argSeparator: '|' })
  async poll ({ msg, args, l } : CommandArgs) {
    // Validate answer count
    if (args.length > 16) return msg.reply(l!.poll.tooManyAnswers)
    if (args.length < 3) return msg.reply(l!.poll.notEnoughAnswers)

    const poll = {
      question: args[0] as string,
      answers: args.slice(1) as string[]
    }

    const embed = {
      color: 0xB1FF86,
      title: poll.question,
      description: poll.answers.map((answer, ix) => `${this.answerSymbols[ix]} - ${answer}`).join('\n')
    }

    const pollMsg = await msg.channel.send(l!.gen(l!.poll.pollStarted, msg.author.toString()), { embed }) as Message
    for (let i = 0; i < poll.answers.length; i++) {
      await pollMsg.react(this.answerSymbols[i])
    }
  }
}

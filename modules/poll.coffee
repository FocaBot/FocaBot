options = ['🇦','🇧', '🇨','🇩','🇪','🇫','🇬','🇭','🇮','🇯','🇰','🇱','🇲','🇳','🇴']

class PollModule extends BotModule
  init: ->
    @registerCommand 'poll', { argSeparator: '|' }, ({ msg, args, l })=>
      # Validate poll
      return msg.reply l.poll.tooManyAnswers if args.length > 16
      return msg.reply l.poll.notEnoughAnswers if args.length < 3
      poll =
        question: args[0]
        answers: args.slice(1)
      embed =
        color: 0xB1FF86
        title: poll.question
        description: ''
      for answer,i in poll.answers
        embed.description += "#{options[i]} - #{answer}\n"
      m = await msg.channel.send l.gen(l.poll.pollStarted, msg.author), { embed }
      try await m.react(options[i]) for i in [0..poll.answers.length-1]

module.exports = PollModule

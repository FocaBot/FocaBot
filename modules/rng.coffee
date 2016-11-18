# RNGeesoos!!!!
Chance = require 'chance'

class RNGModule extends BotModule
  init: =>
    @chance = new Chance
    # The classic
    @registerCommand 'roll', (msg, args)=>
      max = parseInt(args) or 100
      result = @chance.integer {min: 0, max}
      msg.channel.sendMessage "#{msg.author.mention} 🎲 rolls **#{result}/#{max}**."

    # Totally not stolen from ChavezBot
    @registerCommand 'choose', { argSeparator: ';' }, (msg, args)=>
      if args.length < 2
        msg.reply 'Not enough items to choose from. Remember to use `;` to separate them.'
      else
        msg.reply "I choose #{@chance.pickone args}"

    # Totally not stolen from Wikipedia
    @registerCommand '8ball', (msg, args)=> msg.reply '🎱' + @chance.pickone [
      "It is certain"
      "It is decidedly so"
      "Without a doubt"
      "Yes, definitely"
      "You may rely on it"
      "As I see it, yes"
      "Most likely"
      "Outlook good"
      "Yes"
      "Signs point to yes"
      "Reply hazy try again"
      "Ask again later"
      "Better not tell you now"
      "Cannot predict now"
      "Concentrate and ask again"
      "Don't count on it"
      "My reply is no"
      "My sources say no"
      "Outlook not so good"
      "Very doubtful"
    ]

    # Not actually random but ¯\_(ツ)_/¯
    @registerCommand 'rate', (msg, args)=>
      return if not args
      for i in [0 ... args.length]
        chr   = args.charCodeAt(i)
        hash  = ((hash << 5) - hash) + chr
        hash |= 0
      rate = Math.ceil(((hash & 0xFF) / 255) * 10)
      msg.reply "I'd give #{args} a #{rate}/10."

module.exports = RNGModule
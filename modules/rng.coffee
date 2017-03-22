# RNGeesoos!!!!
Chance = require 'chance'

class RNGModule extends BotModule
  init: =>
    @chance = new Chance
    # The classic
    @registerCommand 'roll', (msg, args, d)=>
      return unless d.data.allowRng
      unless /\d+d\d+/.test(args)
        args = if parseInt(args) then "1d#{parseInt(args)}" else '1d100'
      result = @chance.rpg(args)
      reply = "#{msg.author.mention} 🎲 rolls `#{result}`."
      total = 0
      total += dice for dice in result
      reply += "\n\n**Total**: __#{total}__" if result.length > 1
      msg.channel.sendMessage(reply)

    # Totally not stolen from ChavezBot
    @registerCommand 'choose', { argSeparator: ';' }, (msg, args, d)=>
      return unless d.data.allowRng
      if args.length < 2
        msg.reply 'Not enough items to choose from. Remember to use `;` to separate them.'
      else
        msg.reply "I choose #{@chance.pickone args}"

    # Totally not stolen from Wikipedia
    @registerCommand '8ball', (msg, args, d)=> msg.reply '🎱' + @chance.pickone [
      'It is certain'
      'It is decidedly so'
      'Without a doubt'
      'Yes, definitely'
      'You may rely on it'
      'As I see it, yes'
      'Most likely'
      'Outlook good'
      'Yes'
      'Signs point to yes'
      'Reply hazy try again'
      'Ask again later'
      'Better not tell you now'
      'Cannot predict now'
      'Concentrate and ask again'
      "Don't count on it"
      'My reply is no'
      'My sources say no'
      'Outlook not so good'
      'Very doubtful'
    ] if d.data.allowRng

    # Not actually random but ¯\_(ツ)_/¯
    @registerCommand 'rate', (msg, args, d)=>
      return unless args and d.data.allowRng
      for i in [0 ... args.length]
        chr   = args.charCodeAt(i)
        hash  = ((hash << 5) - hash) + chr
        hash |= 0
      rate = Math.ceil(((hash & 0xFF) / 255) * 10)
      msg.reply "I'd give #{args} a #{rate}/10."

module.exports = RNGModule

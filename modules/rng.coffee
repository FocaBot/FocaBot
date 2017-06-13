# RNGeesoos!!!!
Chance = require 'chance'

class RNGModule extends BotModule
  init: ->
    chance = new Chance
    # The classic
    @registerCommand 'roll', ({ msg, args, l })=>
      unless /\d+d\d+/.test(args)
        args = if parseInt(args) then "1d#{parseInt(args)}" else '1d100'
      result = chance.rpg(args)
      reply = l.gen(l.rng.roll, msg.member, result)
      total = 0
      total += dice for dice in result
      reply += "\n\n#{l.gen(l.rng.total, total)}" if result.length > 1
      msg.channel.send(reply)

    # Totally not stolen from ChavezBot
    @registerCommand 'choose', { argSeparator: ';' }, ({ msg, args, l })=>
      if args.length < 2
        msg.reply l.rng.notEnoughItems
      else
        msg.reply l.gen(l.rng.choice, chance.pickone args)

    # Totally not stolen from Wikipedia
    @registerCommand '8ball', ({ msg, l })=> msg.reply '🎱' + chance.pickone l.rng['8ball']

    # Not actually random but ¯\_(ツ)_/¯
    @registerCommand 'rate', ({ msg, args, l })=>
      return unless args
      for i in [0 ... args.length]
        chr   = args.charCodeAt(i)
        hash  = ((hash << 5) - hash) + chr
        hash |= 0
      rate = Math.ceil(((hash & 0xFF) / 255) * 10)
      msg.reply l.gen(l.rng.rate, args, rate)

module.exports = RNGModule

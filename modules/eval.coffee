CoffeeScript = require 'coffee-script'
prune = require 'json-prune'
format = require 'json-format'
formatSettings =
  type: 'space',
  size: 2
G = {}

class EvalModule
  constructor: (@engine)->
    {@bot, @commands} = @engine
    evalOptions = 
      ownerOnly: true
    # CoffeeScript Eval Command
    @cevalCommand = @commands.registerCommand 'ceval', evalOptions, @cevalCommandFunction
    # JavaScript Eval Command
    @evalCommand  = @commands.registerCommand 'eval', evalOptions, @evalCommandFunction

  cevalCommandFunction: (msg, args, bot, engine)=>
    # Utillity Functions
    p = (text)-> bot.sendMessage msg.channel, text
    j = (obj, length)->
      pruned = prune obj, length
      p "```json\n#{format(JSON.parse(pruned),formatSettings)}\n```"
    # Eval
    eval(CoffeeScript.compile(args, bare: true))
  
  evalCommandFunction: (msg, args, bot, engine)=>
    # Utillity Functions
    p = (text)-> bot.sendMessage msg.channel, text
    j = (obj)-> p JSON.stringify obj
    # Eval
    eval(args)

  shutdown: =>
    @commands.unregisterCommands [@cevalCommand, @evalCommand]

module.exports = EvalModule

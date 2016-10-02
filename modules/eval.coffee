CoffeeScript = require 'coffee-script'
prune = require 'json-prune'
format = require 'json-format'
reload = require('require-reload')(require)
formatSettings =
  type: 'space',
  size: 2
T = {}

class EvalModule extends BotModule
  init: =>
    { @webHooks } = @engine
    evalOptions = 
      ownerOnly: true
    # CoffeeScript Eval Command
    @registerCommand 'eval', evalOptions, (msg, args, bot, engine)=>
      p = (text)-> msg.channel.sendMessage text
      j = (obj, length)->
        pruned = prune obj, length
        p "```json\n#{format(JSON.parse(pruned),formatSettings)}\n```"
      eval(CoffeeScript.compile(args, bare: true))
    # JavaScript Eval Command
    @registerCommand 'jseval', evalOptions, (msg, args, bot, engine)=>
      p = (text)-> msg.channel.sendMessage text
      j = (obj, length)->
        pruned = prune obj, length
        p "```json\n#{format(JSON.parse(pruned),formatSettings)}\n```"
      eval args
    @registerCommand 'sudo', { adminOnly: true, argSeparator: ' ' }, (msg, args)=>
      return if not msg.mentions[0]
      name = msg.mentions[0].memberOf(msg.guild).nick or msg.mentions[0].memberOf(msg.guild).nick
      @webHooks.getForChannel(msg.channel, true)
      .then (hook)=>
        hook.execSlack {
          username: name
          icon_url: msg.mentions[0].avatarURL
          text: args.slice(1).join(' ')
        }

module.exports = EvalModule

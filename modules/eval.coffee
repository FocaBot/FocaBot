CoffeeScript = require 'coffeescript'
prune = require 'json-prune'
format = require 'json-format'
reload = require('require-reload')(require)
formatSettings =
  type: 'space',
  size: 2
T = {}

class EvalModule extends BotModule
  init: =>
    evalOptions =
      ownerOnly: true
      allowDM: true
    # CoffeeScript Eval Command
    @registerCommand 'eval', evalOptions, (msg, args, d, bot, engine)->
      p = (text)-> msg.channel.sendMessage text
      j = (obj, length)->
        pruned = prune obj, length
        p "\`\`\`json\n#{format(JSON.parse(pruned),formatSettings)}\n\`\`\`"
      eval(CoffeeScript.compile("(=>\n#{args.replace(/\n/, '\n  ')}\n)()", bare: true))
    # JavaScript Eval Command
    @registerCommand 'jseval', evalOptions, (msg, args, d, bot, engine)->
      p = (text)-> msg.channel.sendMessage text
      j = (obj, length)->
        pruned = prune obj, length
        p "\`\`\`json\n#{format(JSON.parse(pruned),formatSettings)}\n\`\`\`"
      eval "(async function () {#{args}})()"

module.exports = EvalModule

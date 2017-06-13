CoffeeScript = require 'coffeescript'
prune = require 'json-prune'
format = require 'json-format'
reload = require('require-reload')(require)
formatSettings =
  type: 'space',
  size: 2
G = {}

class EvalModule extends BotModule
  init: ->
    # coffeelint: disable=max_line_length
    owner = ownerOnly: true, allowDM: true
    # CoffeeScript Eval Command
    @registerCommand 'eval', owner, ({ msg, args, data, saveData, settings, locale, bot, discord })->
      p = (text)-> msg.channel.send text
      j = (obj, length = 2)->
        pruned = prune obj, length
        p "\`\`\`json\n#{format(JSON.parse(pruned),formatSettings)}\n\`\`\`"
      eval(CoffeeScript.compile("(=>\n  #{args.replace(/^/gm, '  ')}\n)()", bare: true))
    # JavaScript Eval Command
    @registerCommand 'jseval', owner, ({ msg, args, data, saveData, settings, locale, bot, discord })->
      p = (text)-> msg.channel.send text
      j = (obj, length = 2)->
        pruned = prune obj, length
        p "\`\`\`json\n#{format(JSON.parse(pruned),formatSettings)}\n\`\`\`"
      eval "(async function () {#{args}})()"
    # coffeelint: enable=max_line_length

module.exports = EvalModule

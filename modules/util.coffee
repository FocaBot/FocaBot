moment = require 'moment'
mathjs = require 'mathjs'

class Util extends BotModule
  init: =>
    Core.util = @

  parseTime: (time)->
    t = time.split(':').reverse()
    moment.duration {
      seconds: t[0]
      minutes: t[1]
      hours:   t[2]
    }
    .asSeconds()

  evalExpr: (e)->
    expr = e
    for param in arguments
      e = e.replace '{n}', param if typeof param is 'number'
    mathjs.eval(e)

  delay: (ms)-> new Promise (resolve)-> setTimeout((-> resolve()), ms)

module.exports = Util
moment = require 'moment'
mathjs = require 'mathjs'
request = require 'request-promise'

class Util extends BotModule
  init: ->
    Core.util = @

  parseTime: (time)->
    t = time.toString().split(':').reverse()
    moment.duration {
      seconds: t[0]
      minutes: t[1]
      hours: t[2]
    }
    .asSeconds()

  evalExpr: (e)->
    expr = e
    for param in arguments
      e = e.replace '{n}', param if typeof param is 'number'
    mathjs.eval(e)

  delay: (ms)-> new Promise (resolve)-> setTimeout((-> resolve()), ms)

  # I don't like how d.js implements the typing indicator (yeah i'm autistic)
  sendTyping: (channel)->
    request("https://discordapp.com/api/v6/channels/#{channel.id}/typing", {
      method: 'POST'
      json: true
      headers: Authorization: "Bot #{Core.bot.token}"
    })

module.exports = Util

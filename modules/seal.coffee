Chance = require 'chance'
request = require 'request'

class SealModule extends BotModule
  init: ->
    @registerCommand 'seal', { allowDM: true }, ({ msg, args })->
      chance = new Chance()
      # Get a seal from randomse.al
      seal = chance.integer { min: 1, max: 83 }
      seal = ('0000' + seal).substring(seal.toString().length)
      msg.channel.send "https://randomse.al/seals/#{seal}.jpg"

module.exports = SealModule

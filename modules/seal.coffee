Chance = require 'chance'
request = require 'request'

class SealModule extends BotModule
  init: ->
    @registerCommand 'seal', { allowDM: true }, ({ msg, args })=>
      chance = new Chance()
      # Get a seal from randomse.al
      seal = chance.integer { min: 1, max: 83 }
      seal = ('0000' + seal).substring(seal.toString().length)
      msg.channel.send "https://randomse.al/seals/#{seal}.jpg"

    # coffeelint: disable=max_line_length
    # PRAISE THE SEAL!
    @registerCommand 'pray', { allowDM: true }, ({ msg, args })=>
      msg.channel.send '', embed: image: url: 'https://cdn.discordapp.com/attachments/248274146931245056/327639305172287488/praise_the_seal.jpg'
    # coffeelint: enable=max_line_length

module.exports = SealModule

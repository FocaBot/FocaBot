Chance = require 'chance'
request = require 'request'

class SealModule extends BotModule
  init: =>
    @registerCommand 'seal', { allowDM: true }, (msg, args, d)->
      return unless d.data.allowImages
      chance = new Chance()
      if chance.integer({ min: 0, max: 100 }) > 2
        # Get a seal from randomse.al
        seal = chance.integer { min: 1, max: 83 }
        seal = ('0000' + seal).substring(seal.toString().length)
        msg.channel.sendMessage "https://randomse.al/seals/#{seal}.jpg"
      else
        # Send... this...
        msg.channel.uploadFile request('''
        http://danbooru.donmai.us/data/__original_drawn_by_maldives\
        __71425fe9ff40add3a301d5c5d0cf3baf.png'
        '''), 'seal.png', 'A strange seal appeared.'

module.exports = SealModule

Bing = require('node-bing-api')({ accKey: process.env.BING_KEY })
Chance = require 'chance'
request = require 'request'

class SealModule extends BotModule
  init: =>
    @registerCommand 'seal', (msg, args)->
      # Find a seal picture on Bing
      Bing.images 'sea lion', { top: 50 }, (error, res, body)=>
        { results } = body.d
        chance = new Chance()
        # Pick a random result
        image = chance.pickone results
        # Get the extension
        ext = image.ContentType.split('/')[1]
        .replace 'jpeg', 'jpg'
        .replace 'animatedgif', 'gif'
        name = image.Title + '.' + ext
        if chance.integer { min: 0, max: 100 } > 10
          # Send the pic
          msg.channel.uploadFile request(image.MediaUrl), name
        else
          # Send... this...
          msg.channel.uploadFile request(
            'http://danbooru.donmai.us/data/__original_drawn_by_maldives__71425fe9ff40add3a301d5c5d0cf3baf.png'
          ), 'seal.png', 'A strange seal appeared.'

module.exports = SealModule

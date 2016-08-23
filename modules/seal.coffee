Bing = require('node-bing-api')({ accKey: "+hIxFKrrBJtvi2IA1s9xzpwJDTcHFKDQmbInW+quUWU" })
Chance = require 'chance'

class SealModule
  constructor: (@engine)->
    {@bot, @commands} = @engine
    @commands.registerCommand 'seal', { }, @sealFunc

  sealFunc: (msg, args)->
    # Find a seal picture on Bing
    Bing.images 'sea lion', { top: 50 }, (error, res, body)=>
      { results } = body.d
      chance = new Chance()
      # Pick a random result
      image = chance.pickone results
      # Get the extension
      ext = image.ContentType.split('/')[1]
      name = image.title + '.' + ext
      # Send the pic
      @bot.sendMessage msg.channel, { file: {
        file: image.MediaUrl
        name
      } }

  shutdown: =>

module.exports = SealModule

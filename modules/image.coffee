Bing = require('node-bing-api')({ accKey: process.env.BING_KEY })
Chance = require 'chance'
request = require 'request'

class ImageModule extends BotModule
  init: =>
    @registerCommand 'img', (msg, args)=> Bing.images args, { top: 1 }, (error, res, body)=>
      { results } = body.d
      msg.channel.uploadFile request(results[0].MediaUrl), @getImageName(results[0])

    @registerCommand 'rimg', (msg, args)=> Bing.images args, { top: 50 }, (error, res, body)=>
      { results } = body.d
      chance = new Chance()
      image = chance.pickone results
      msg.channel.uploadFile request(image.MediaUrl), @getImageName(image)

    # NSFW (sorry, WET code)
    @registerCommand 'imgn', (msg, args)=> Bing.images args, { top: 1, adult: 'Off' }, (error, res, body)=>
      { results } = body.d
      msg.channel.uploadFile request(results[0].MediaUrl), @getImageName(results[0])

    @registerCommand 'rimgn', (msg, args)=> Bing.images args, { top: 50, adult: 'Off' }, (error, res, body)=>
      { results } = body.d
      chance = new Chance()
      image = chance.pickone results
      msg.channel.uploadFile request(image.MediaUrl), @getImageName(image)
  
  getImageName: (image)=>
    ext = image.ContentType.split('/')[1]
    .replace 'jpeg', 'jpg'
    .replace 'animatedgif', 'gif'
    name = image.Title + '.' + ext

module.exports = ImageModule

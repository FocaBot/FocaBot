Chance = require 'chance'
request = require 'request'
{ type } = Core.db

# Cache results in DB
CachedResults = Core.db.createModel 'SearchResults', {
  id: type.string()
  query: type.string()
  nsfw: type.boolean()
  response: type.object()
  expires: type.date()
}

# Google Image Search API
CSE = require('request-promise').defaults {
  baseUrl: 'https://www.googleapis.com/customsearch/'
  simple: true
}

class ImageModule extends BotModule
  init: =>
    @chance = new Chance()

    @registerCommand 'img', {
      allowDM: true
      aliases: ['rimg','imgn','rimgn']
      includeCommandNameInArgs: true
    }, (msg, args, d)=>
      random = args[0].indexOf('rimg') >= 0
      nsfw = d.data.allowNSFW and args[0].indexOf('imgn') >= 0

      @getImages(args[1], nsfw).then (r)=>
        return msg.reply 'No results.' if not r.items?
        if not random
          msg.channel.uploadFile request(r.items[0].link), @getImageName(r.items[0])
        else
          image = @chance.pickone r.items
          msg.channel.uploadFile request(image.link), @getImageName(image)
      .catch (err)=>
        return msg.reply 'Daily limit exceeded.' if err.statusCode is 403
        msg.reply 'Something went wrong.'
  
  getImages: (query, nsfw)=>
    safe = 'high'
    safe = 'off' if nsfw
    CachedResults.filter({ query, nsfw }).run().then (results)=>
      # Check if the query is already cached and not expired
      if results[0]? and results[0].expires - Date.now() > 0
        return Promise.resolve(results[0].response)
      else
        r = results[0] or new CachedResults({ query })
        # Fetch the results straight from Google
        CSE.get 'v1', { json: true, qs: {
          searchType: 'image'
          q: query
          cx: process.env.GOOGLE_CX
          key: process.env.GOOGLE_KEY
          safe
        }}
        .then (resp)=>
          r.response = resp
          r.expires = new Date(Date.now() + 0x48190800) # 14 days
          r.save()
        .then (obj)=>
          return obj.response

  getImageName: (image)=>
    ext = image.mime.split('/')[1] or 'jpg' # jpg if no extension set
    .replace 'jpeg', 'jpg'
    .replace 'animatedgif', 'gif'
    name = image.title + '.' + ext

module.exports = ImageModule

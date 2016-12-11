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

# Imgur fallback
Imgur = require('request-promise').defaults {
  baseUrl: 'https://api.imgur.com/3/'
  headers:
    Authorization: "Client-ID #{process.env.IMGUR_KEY}"
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
      nsfw = (d.data.allowNSFW or msg.channel.name.indexOf('nsfw') >= 0) and args[0].indexOf('imgn') >= 0

      @getImages(args[1], nsfw).then (r)=>
        return msg.reply 'No results.' if not r.items?
        if not random
          msg.reply '', false, {
            title: '[click for sauce]'
            url: r.items[0].image.contextLink
            image: { url: r.items[0].link }
          }
        else
          image = @chance.pickone r.items
          msg.reply '', false, {
            title: '[click for sauce]'
            url: image.image.contextLink
            image: { url: image.link }
          }
      .catch (err)=>
        if err.statusCode is 403
          # Try imgur as fallback
          return @commands['imgur'].func(msg, args, { nsfw, data: d.data })
        msg.reply 'Something went wrong.'

    @registerCommand 'imgur', (msg, args, d)=>
      
      try
        # Find something on imgur
        results = await Imgur.get('/gallery/search/top/0/', json: true, qs: {
          q: args
        })
        # Random by default
        if results.success and results.data
          nsfw = if d.nsfw? then d.nsfw else d.data.allowNSFW
          image = @chance.pickone results.data.filter (i)=>
            not i.is_album and not i.is_ad and (nsfw or not i.nsfw)
          msg.reply '', false, {
            title: '[click for sauce]'
            url: "https://imgur.com/#{image.id}"
            image: { url: image.link }
          }
        else msg.reply 'No results.'
      catch err
        if err.statusCode is 403
          return msg.reply 'Daily limit exceeded.'
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

module.exports = ImageModule

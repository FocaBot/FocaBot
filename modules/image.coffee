Chance = require 'chance'
request = require 'request'
# sorry about this, i lost a bet
tumblr = require('tumblr.js').createClient { consumer_key: process.env.TUMBLR_CONSUMER_KEY }

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

# Giphy
Giphy = require('request-promise').defaults {
  baseUrl: 'http://api.giphy.com/v1/gifs/'
  simple: true
}

class ImageModule extends BotModule
  init: ->
    chance = new Chance()

    @registerCommand 'img', {
      allowDM: true
      aliases: ['rimg','imgn','rimgn']
      includeCommandNameInArgs: true
    }, ({ msg, args, s, l })=>
      random = args[0].indexOf('rimg') >= 0
      nsfw = (s.allowNSFW or msg.channel.nsfw) and args[0].indexOf('imgn') >= 0
      # Find the image
      try
        r = await @getImages(args[1], nsfw)
        return msg.reply l.generic.noResults unless r.items?
        # Pick the first result by default
        image = r.items[0]
        # Pick a random result if using the random command
        image = chance.pickone r.items if random
        # Send the image
        msg.reply '', embed: {
          title: l.generic.sauceBtn
          url: image.image.contextLink
          image: { url: image.link }
        }
      catch err
        if err.statusCode is 403
          return msg.reply l.image.dailyLimit
        msg.reply l.generic.error

    @registerCommand 'imgur', ({ msg, args, l, s })=>
      try
        # Find something on imgur
        results = await Imgur.get('/gallery/search/top/0/', json: true, qs: {
          q: args
        })
        # Random by default
        if results.success and results.data
          nsfw = (s.allowNSFW or msg.channel.nsfw)
          image = chance.pickone results.data.filter (i)=>
            not i.is_album and not i.is_ad and (nsfw or not i.nsfw)
          msg.reply '', embed: {
            title: l.generic.sauceBtn
            url: "https://imgur.com/#{image.id}"
            image: { url: image.link }
          }
        else msg.reply l.generic.noResults
      catch err
        if err.statusCode is 403
          return msg.reply l.image.dailyLimit
        if err.statusCode is 404
          return msg.reply l.generic.noResults
        msg.reply l.generic.error

    @registerCommand 'tumblr', ({ msg, args, l })=>
      # Query the tumblr tag
      tumblr.taggedPosts args, (err, data)=>
        return msg.reply l.generic.error if err
        # Filter only image results
        try
          results = data.filter((r)=> r.type is 'photo')
          return msg.reply l.generic.noResults unless results.length
          # Pick a random image
          image = chance.pickone results
          msg.reply '', embed: {
            title: l.generic.sauceBtn
            url: image.post_url
            image: { url: image.photos[0].original_size.url }
          }
        catch e
          Core.log e,2
          msg.reply l.generic.error

    @registerCommand 'giphy', { aliases: ['gif'], allowDM: true }, ({ msg, args, locale })=>
      try
        { data } = await Giphy.get('search', {
          json: true, qs: { q: args, api_key: 'dc6zaTOxFJmzC' }
        })
      return msg.reply 'No results' unless data.length
      msg.reply chance.pickone(data).bitly_url

  getImages: (query, nsfw)->
    safe = 'high'
    safe = 'off' if nsfw
    # Fetch the results straight from Google
    result = await CSE.get 'v1', { json: true, qs: {
      searchType: 'image'
      q: query
      cx: process.env.GOOGLE_CX
      key: process.env.GOOGLE_KEY
      safe
    } }
    return result

module.exports = ImageModule

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

class ImageModule extends BotModule
  init: =>
    @chance = new Chance()
    { @prefix } = Core.settings

    @registerCommand 'img', {
      allowDM: true
      aliases: ['rimg','imgn','rimgn']
      includeCommandNameInArgs: true
    }, (msg, args, d)=>
      return unless d.data.allowImages
      random = args[0].indexOf('rimg') >= 0
      nsfw = (d.data.allowNSFW or msg.channel.name.indexOf('nsfw') >= 0) and
             args[0].indexOf('imgn') >= 0
      # Find the image
      try
        r = await @getImages(args[1], nsfw)
        return msg.reply 'No results.' unless r.items?
        # Pick the first result by default
        image = r.items[0]
        # Pick a random result if using the random command
        image = @chance.pickone r.items if random
        # Send the image
        msg.reply '', false, {
          title: '[click for sauce]'
          url: r.items[0].image.contextLink
          image: { url: r.items[0].link }
        }
      catch err
        if err.statusCode is 403
          return msg.reply "Daily limit exceeded for this command. (Try #{@prefix}imgur)."
        msg.reply 'Something went wrong.'

    @registerCommand 'imgur', (msg, args, d)=>
      return unless d.data.allowImages
      try
        # Find something on imgur
        results = await Imgur.get('/gallery/search/top/0/', json: true, qs: {
          q: args
        })
        # Random by default
        if results.success and results.data
          nsfw = (d.data.allowNSFW or msg.channel.name.indexOf('nsfw') >= 0)
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

    @registerCommand 'tumblr', (msg, args, d)=>
      # Tumblr's API doesn't seem to offer a way to filter out NSFW content, so yeah...
      return unless d.data.allowImages and
                    (d.data.allowNSFW or msg.channel.name.indexOf('nsfw') >= 0)
      # Query the tumblr tag
      tumblr.taggedPosts args, (err, data)=>
        return msg.reply 'Something went wrong.' if err or data.meta.status isnt 200
        # Filter only image results
        try
          results = data.response.filter((r)=> r.type is 'photo')
          return msg.reply 'No results.' unless results.length
          # Pick a random image
          image = @chance.pickone results
          msg.reply '', false, {
            title: '[click for sauce]'
            url: image.post_url
            image: { url: image.photos[0].original_size.url }
          }
        catch e
          Core.log e,2
          msg.reply 'Something went wrong'

  getImages: (query, nsfw)=>
    safe = 'high'
    safe = 'off' if nsfw
    dbq = "CachedSearch:#{query}"
    dbq = "CachedSearchNSFW:#{query}" if nsfw
    result = await Core.data.get(dbq)
    # Check if the query is already cached
    return result if result?
    # Fetch the results straight from Google
    result = await CSE.get 'v1', { json: true, qs: {
      searchType: 'image'
      q: query
      cx: process.env.GOOGLE_CX
      key: process.env.GOOGLE_KEY
      safe
    } }
    await Core.data.set(dbq, result, 0x127500)
    return result

module.exports = ImageModule

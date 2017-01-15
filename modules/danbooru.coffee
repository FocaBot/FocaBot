request = require 'request'
{ type } = Core.db

danbooru = require('request-promise').defaults {
  baseUrl: 'https://danbooru.donmai.us/'
  auth:
    user: process.env.DANBOORU_LOGIN
    pass: process.env.DANBOORU_API_KEY
  simple: true
}

safebooru = require('request-promise').defaults {
  baseUrl: 'https://safebooru.donmai.us/'
  auth:
    user: process.env.DANBOORU_LOGIN
    pass: process.env.DANBOORU_API_KEY
  simple: true
}

Waifu = Core.db.createModel 'Waifu', {
  id: type.string()
  user: type.string()
  waifu: type.string()
}

class DanbooruModule extends BotModule
  init: =>
    {@prefix} = @engine.settings

    @registerCommand 'danbooru', {
      allowDM: true
      aliases: ['d', 'safebooru', 'safe']
      includeCommandNameInArgs: true
    }, (msg, args, d)=>
      switch args[0]
        when 'danbooru', 'd'
          host = 'danbooru.donmai.us'
          b = danbooru
        when 'safebooru', 'safe'
          host = 'safebooru.donmai.us'
          b = safebooru
      tags = args[1]
      # Rate limiting
      if d.danbooruDate
        return msg.reply 'Rate limit excedeed. Wait a few seconds.' if (new Date() - d.danbooruDate) < 3000
      d.danbooruDate = new Date()
      # NSFW Filter
      b = safebooru if not d.data.allowNSFW and msg.channel.name.indexOf('nsfw') < 0
      try
        r = await b.get('posts.json', { json: true, qs: { random: true, tags } })
      catch
        # the random option of the Danbooru API doesn't work sometimes
        try r = await b.get('posts.json', { json: true, qs: { tags } })
        catch error
          Core.log error, 2
          msg.reply 'Something went wrong.'
      return msg.reply 'No results.' if not r.length
      msg.reply '', false, {
        title: '[click for sauce]'
        url: "https://#{host}/posts/#{r[0].id}"
        image: { url: "https://#{host + r[0].file_url}" }
      }

    @registerCommand 'setwaifu', { allowDM: true, aliases: ['sw'] }, (msg, args, d)=>
      return if not d.data.allowWaifus
      waifu = (args.match(/\S+/) or [''])[0]
      return msg.reply "Usage: ```#{@prefix}setWaifu <safebooru_tag>```" if not waifu
      try
        # Do a dummy search to check if the tag is valid
        r = await safebooru.get('/posts.json', { json: true, qs: { tags: 'solo ' + waifu } })
        return msg.reply 'Invalid safebooru tag.' if not r.length
        # Check the DB for an existent waifu entry for the current user
        w = (await Waifu.filter({ user: msg.author.id }).run())[0]
        # If none, create a new entry
        w = new Waifu { user: msg.author.id } if not w?
        w.waifu = waifu
        await w.save()
        msg.reply 'Success.'
      catch error
        Core.log error, 2
        msg.reply 'Something went wrong.'

    @registerCommand 'waifu', { allowDM: true, aliases: ['w'] }, (msg, args, d)=>
      return if not d.data.allowWaifus
      # Rate limiting
      if d.danbooruDate
        return msg.reply 'Rate limit excedeed. Wait a few seconds.' if (new Date() - d.danbooruDate) < 3000
      d.danbooruDate = new Date()
      try
        # Get the waifu entry for the current user
        w = (await Waifu.filter({ user: msg.author.id }).run())[0]
        return msg.reply "Run the #{@prefix}setWaifu command first." if not w?
        # Make a safebooru search
        try
          r = await safebooru.get('/posts.json', { json: true, qs: { random: true, tags: 'solo ' + w.waifu } })
        catch
          r = await safebooru.get('/posts.json', { json: true, qs: { tags: 'solo ' + w.waifu } })
        return msg.reply 'No results.' if not r.length
        msg.reply '', false, {
          title: '[click for sauce]'
          url: "https://safebooru.donmai.us/posts/#{r[0].id}"
          image: { url: "https://safebooru.donmai.us#{r[0].file_url}" }
        }
      catch error
        Core.log error, 2
        msg.reply 'Something went wrong.'

module.exports = DanbooruModule

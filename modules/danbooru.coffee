# APIs
danbooru = { baseUrl: 'https://danbooru.donmai.us/', simple: true }
safebooru = { baseUrl: 'https://safebooru.donmai.us/', simple: true }
# Authenticate requests if there's an API key present
danbooru.auth = safebooru.auth = {
  user: process.env.DANBOORU_LOGIN
  pass: process.env.DANBOORU_API_KEY
} if process.env.DANBOORU_API_KEY
# request-promise instances
danbooru = require('request-promise').defaults danbooru
safebooru = require('request-promise').defaults safebooru

class DanbooruModule extends BotModule
  init: =>
    { @prefix } = @engine.settings

    @registerCommand 'danbooru', { allowDM: true, aliases: ['d'] }, (msg, tags, d)=>
      return unless d.data.allowImages
      b = danbooru
      # NSFW Filter
      b = safebooru unless d.data.allowNSFW or msg.channel.name.indexOf('nsfw') >= 0
      # Blacklisted tags (discord community guidelines)
      for tag in tags.split(' ')
        if tag in ['loli', 'rori', 'shota', 'lolicon', 'toddlercon'] then return msg.reply '', false, {
          image:
            url: 'https://cdn.discordapp.com/attachments/244581077610397699/315655455143886850/Screenshot_from_2017-05-20_21-01-03.png'
        }
        if tag in ['gore', 'guro'] then return msg.reply 'nope', false, {
          image:
            url: 'http://25.media.tumblr.com/tumblr_lqhsh2zVkZ1qjlcvoo1_500.jpg'
        }
      # Make the search
      r = await b.get('posts.json', { json: true, qs: { random: true, tags } })
      return msg.reply 'No results.' unless r.length
      # Send the picture
      msg.reply '', false, {
        title: '[click for sauce]'
        url: "https://danbooru.donmai.us/posts/#{r[0].id}"
        image: { url: "https://danbooru.donmai.us#{r[0].file_url}" }
      }

    @registerCommand 'safebooru', { allowDM: true, aliases: ['safe'] }, (msg, tags, d)=>
      return unless d.data.allowImages
      # Make the search
      r = await safebooru.get('posts.json', { json: true, qs: { random: true, tags } })
      return msg.reply 'No results.' unless r.length
      # Send the picture
      msg.reply '', false, {
        title: '[click for sauce]'
        url: "https://safebooru.donmai.us/posts/#{r[0].id}"
        image: { url: "https://safebooru.donmai.us#{r[0].file_url}" }
      }

    @registerCommand 'setwaifu', { allowDM: true, aliases: ['sw'] }, (msg, args, d)=>
      return unless d.data.allowWaifus and d.data.allowImages
      waifu = (args.match(/\S+/) or [''])[0]
      return msg.reply "Usage: ```#{@prefix}setWaifu <safebooru_tag>```" unless waifu
      try
        # Do a dummy search to check if the tag is valid
        r = await safebooru.get('/posts.json', { json: true, qs: { tags: 'solo ' + waifu } })
        return msg.reply 'Invalid safebooru tag.' unless r.length
        # Save the new waifu to the DB
        await Core.data.set("UserWaifu:#{msg.author.id}", waifu)
        msg.reply 'Success!'
      catch error
        Core.log error, 2
        msg.reply 'Something went wrong.'

    @registerCommand 'waifu', { allowDM: true, aliases: ['w'] }, (msg, args, d)=>
      return unless d.data.allowWaifus and d.data.allowImages
      try
        # Get the waifu entry for the current user
        waifu = await Core.data.get("UserWaifu:#{msg.author.id}")
        return msg.reply "Run the #{@prefix}setWaifu command first." if not waifu?
        # Make a safebooru search
        r = await safebooru.get('/posts.json', {
          json: true, qs: { random: true, tags: "solo #{waifu} #{args}" }
        })
        return msg.reply 'No results.' unless r.length
        # Send the picture
        msg.reply '', false, {
          title: '[click for sauce]'
          url: "https://safebooru.donmai.us/posts/#{r[0].id}"
          image: { url: "https://safebooru.donmai.us#{r[0].file_url}" }
        }
      catch error
        Core.log error, 2
        msg.reply 'Something went wrong.'

module.exports = DanbooruModule

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
  init: ->
    @registerParameter 'allowWaifus', { type: Boolean, def: true }

    @registerCommand 'danbooru', { allowDM: true, aliases: ['d'] }, ({ msg, args, s, l })=>
      # Use safebooru if NSFW is disabled
      b = if msg.channel.nsfw or s.allowNSFW then danbooru else safebooru
      # Blacklisted tags (discord community guidelines)
      # coffeelint: disable=max_line_length
      for tag in args.split(' ')
        if tag in ['loli', 'rori', 'shota', 'lolicon', 'toddlercon'] then return msg.reply '', embed: image: url: 'https://cdn.discordapp.com/attachments/244581077610397699/315655455143886850/Screenshot_from_2017-05-20_21-01-03.png'
        if tag in ['gore', 'guro'] then return msg.reply 'nope', embed: image: url: 'http://25.media.tumblr.com/tumblr_lqhsh2zVkZ1qjlcvoo1_500.jpg'
      # coffeelint: enable=max_line_length
      # Get a random post
      try r = await b.get('posts/random.json', { json: true, qs: { tags: args } })
      catch e
        if e.statusCode is 404
          msg.reply l.generic.noResults
        else
          msg.reply l.generic.error
          Core.log e, 2
        return
      url =
        if r.file_url.match(/^http/) then r.file_url
        else "https://danbooru.donmai.us#{r.file_url}"
      # Send the picture
      msg.reply '', embed: {
        title: l.generic.sauceBtn
        url: "https://danbooru.donmai.us/posts/#{r.id}"
        image: { url }
      }

    @registerCommand 'safebooru', { allowDM: true, aliases: ['safe'] }, ({ msg, args, s, l })=>
      # Get a random post
      try r = await safebooru.get('posts/random.json', { json: true, qs: { tags: args } })
      catch e
        if e.statusCode is 404
          msg.reply l.generic.noResults
        else
          msg.reply l.generic.error
          Core.log e, 2
        return
      url =
        if r.file_url.match(/^http/) then r.file_url
        else "https://danbooru.donmai.us#{r.file_url}"
      # Send the picture
      msg.reply '', embed: {
        title: l.generic.sauceBtn
        url: "https://safebooru.donmai.us/posts/#{r.id}"
        image: { url }
      }

    @registerCommand 'setwaifu', { allowDM: true, aliases: ['sw'] }, ({ msg, args, s, l })=>
      return unless s.allowWaifus
      waifu = (args.match(/\S+/) or [''])[0]
      return msg.reply """
      #{l.generic.commandUsage} ```#{s.prefix}setWaifu <safebooru_tag>```
      """ unless waifu
      try
        # Do a dummy search to check if the tag is valid
        r = await safebooru.get('/posts.json', { json: true, qs: { tags: 'solo ' + waifu } })
        return msg.reply l.danbooru.invalidTag unless r.length
        # Save the new waifu to the DB
        await Core.data.set("UserWaifu:#{msg.author.id}", waifu)
        msg.reply l.generic.success
      catch error
        Core.log(error, 2)
        msg.reply l.generic.error

    @registerCommand 'waifu', { allowDM: true, aliases: ['w'] }, ({ msg, args, s, l })=>
      return unless s.allowWaifus
      try
        # Get the waifu entry for the current user
        waifu = await Core.data.get("UserWaifu:#{msg.author.id}")
        return msg.reply l.gen(l.danbooru.noWaifu, "#{s.prefix}setWaifu") if not waifu
        # Run the safebooru command
        Core.commands.run('safebooru', msg, "solo #{waifu} #{args}")
      catch error
        Core.log error, 2
        msg.reply l.generic.error

module.exports = DanbooruModule

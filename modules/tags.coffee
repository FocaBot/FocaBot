Chance = require 'chance'

class TagModule extends BotModule
  init: =>
    { @permissions } = @engine

    @registerCommand '+', { argSeparator: ' ' }, (msg, args, d)=>
      return if msg.author.bot or args.length < 2
      return unless d.data.allowTags
<<<<<<< HEAD
      # Get or create a new tag
      tag = (await Core.data.get("Tag:#{args[0]}")) or []
      # Add the response
      tag.push {
=======
      tag = new Tag {
        key: args[0].toLowerCase()
>>>>>>> Block Tags
        reply: args.slice(1).join(' ')
        by: msg.author.id
      }
      # Save
      await Core.data.set("Tag:#{args[0]}", tag)
      msg.reply 'Tag saved!'

    @registerCommand '-', { argSeparator: ' ' }, (msg, args, d)=>
      return if msg.author.bot or args.length < 1
      return unless d.data.allowTags
<<<<<<< HEAD
      # Try to get existing tag
      tag = await Core.data.get("Tag:#{args[0].toLowerCase()}")
      return msg.reply 'Deleted 0 tag(s)!' unless tag?
      # Filter out the desired tags
      filtered = tag.filter (reply)=>
        if args.length > 1
          # Owner is allowed to delete all responses of a tag
          return false if args[1] is 'all' and @permissions.isOwner msg.author
          # Also allowed to delete responses made by others
          if reply.reply is args.slice(1).join(' ') and @permissions.isOwner msg.author
            return false
          # Other people can only delete their own
          return false if reply.by is msg.author.id and reply.reply is args.slice(1).join(' ')
=======
      q = { by: msg.author.id, key: args[0] }
      if args.length > 1
        if args[1].toLowerCase() is 'all' and @permissions.isOwner msg.author
          q = { key: args[0].toLowerCase() }
        else if @permissions.isOwner msg.author
          q = { key: args[0].toLowerCase(), reply: args.slice(1).join(' ') }
>>>>>>> Block Tags
        else
          # If no response is defined, delete all the responses made by the user
          return false if reply.by is msg.author.id
        true
      # Save the changes
      await Core.data.set("Tag:#{args[0].toLowerCase()}", filtered)
      msg.reply "Deleted #{tags.length - filtered.length} tag(s)!"

    @registerCommand '!', { argSeparator: ' ' }, (msg, args, d)=>
      return if msg.author.bot or args.length < 1
      return unless d.data.allowTags
<<<<<<< HEAD
      # Get the tag
      tag = await Core.data.get("Tag:#{args[0].toLowerCase()}")
      return unless tag?
      # Pick a random reply and send it
      chance = new Chance()
      res = chance.pickone tag
      msg.channel.sendMessage res.reply
=======
      Tag.filter({ key: args[0].toLowerCase() }).run().then (results)=>
        chance = new Chance()
        tag = chance.pickone results
        msg.channel.sendMessage tag.reply
>>>>>>> Block Tags

    @registerCommand 'taginfo', { ownerOnly: true, argSeparator: ' ' }, (msg, args, data, bot)=>
      # Get the tag
      tag = await Core.data.get("Tag:#{args[0].toLowerCase()}")
      return unless tag?
      # Generate a list of responses
      r = ''
      for res in tag
        u = bot.Users.get(tag.by) or { username: 'Unknown', discriminator: tag.by }
        r += "\n(#{u.username}##{u.discriminator}): #{tag.reply.substr(0,32)}..."
      # Send it
      msg.channel.sendMessage r

module.exports = TagModule

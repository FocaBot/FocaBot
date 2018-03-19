Chance = require 'chance'

class TagModule extends BotModule
  init: ->
    @defaultDisabled = true
    { permissions } = Core

    @registerCommand '+', { argSeparator: ' ' }, ({ msg, args, l })=>
      return if msg.author.bot or args.length < 2
      # Get or create a new tag
      tag = (await Core.data.get("Tag:#{args[0].toLowerCase()}")) or []
      # Add the response
      tag.push {
        reply: args.slice(1).join(' ')
        by: msg.author.id
      }
      # Save
      await Core.data.set("Tag:#{args[0].toLowerCase()}", tag)
      msg.reply l.tags.added

    @registerCommand '-', { argSeparator: ' ' }, ({ msg, args, l })=>
      return if msg.author.bot or args.length < 1
      # Try to get existing tag
      tag = await Core.data.get("Tag:#{args[0].toLowerCase()}")
      return msg.reply l.gen(l.tags.deleted, 0) unless tag?
      # Filter out the desired tags
      filtered = tag.filter (reply)=>
        if args.length > 1
          # Owner is allowed to delete all responses of a tag
          return false if args[1] is 'all' and permissions.isOwner msg.author
          # Also allowed to delete responses made by others
          if reply.reply is args.slice(1).join(' ') and permissions.isOwner msg.author
            return false
          # Other people can only delete their own
          return false if reply.by is msg.author.id and reply.reply is args.slice(1).join(' ')
        else
          # If no response is defined, delete all the responses made by the user
          return false if reply.by is msg.author.id
        true
      # Save the changes
      await Core.data.set("Tag:#{args[0].toLowerCase()}", filtered)
      msg.reply l.gen(l.tags.deleted, tag.length - filtered.length)

    @registerCommand '!', { argSeparator: ' ' }, ({ msg, args, l })=>
      return if msg.author.bot or args.length < 1
      # Get the tag
      tag = await Core.data.get("Tag:#{args[0].toLowerCase()}")
      return unless tag?
      # Pick a random reply and send it
      chance = new Chance()
      res = chance.pickone tag
      msg.channel.send l.gen res.reply

    @registerCommand 'taginfo', { ownerOnly: true, argSeparator: ' ' }, ({ msg, args, bot })=>
      # Get the tag
      tag = await Core.data.get("Tag:#{args[0].toLowerCase()}")
      return unless tag?
      # Generate a list of responses
      r = ''
      for res in tag
        u = bot.users.find('id', res.by) or { username: 'Unknown', discriminator: res.by }
        r += "\n(#{u.username}##{u.discriminator}): #{res.reply.substr(0,32)}..."
      # Send it
      msg.channel.send r

module.exports = TagModule

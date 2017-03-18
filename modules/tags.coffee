{ type } = Core.db
Chance = require 'chance'

Tag = Core.db.createModel 'Tag', {
  id: type.string()
  key: type.string()
  reply: type.string()
  by: type.string()
}

class TagModule extends BotModule
  init: =>
    { @permissions } = @engine

    @registerCommand '+', { argSeparator: ' ' }, (msg, args, d)=>
      return if msg.author.bot or args.length < 2
      return unless d.data.allowTags
      tag = new Tag {
        key: args[0].toLowerCase()
        reply: args.slice(1).join(' ')
        by: msg.author.id
      }
      tag.save().then =>
        msg.reply 'Tag saved!'

    @registerCommand '-', { argSeparator: ' ' }, (msg, args, d)=>
      return if msg.author.bot or args.length < 1
      return unless d.data.allowTags
      q = { by: msg.author.id, key: args[0] }
      if args.length > 1
        if args[1].toLowerCase() is 'all' and @permissions.isOwner msg.author
          q = { key: args[0].toLowerCase() }
        else if @permissions.isOwner msg.author
          q = { key: args[0].toLowerCase(), reply: args.slice(1).join(' ') }
        else
          q = { by: msg.author.id, key: args[0].toLowerCase(), reply: args.slice(1).join(' ') }
      Tag.filter(q).run().then (results)=>
        msg.reply "Deleted #{results.length} tag(s)!"
        result.delete() for result in results

    @registerCommand '!', { argSeparator: ' ' }, (msg, args, d)=>
      return if msg.author.bot or args.length < 1
      return unless d.data.allowTags
      Tag.filter({ key: args[0].toLowerCase() }).run().then (results)=>
        chance = new Chance()
        tag = chance.pickone results
        msg.channel.sendMessage tag.reply

    @registerCommand 'taginfo', { ownerOnly: true, argSeparator: ' ' }, (msg, args, data, bot)=>
      return if msg.author.bot or args.length < 1
      Tag.filter({ key: args[0].toLowerCase() }).run().then (results)=>
        r = ''
        for tag in results
          try
            u = bot.Users.get(tag.by)
            r += "\n(#{u.username}##{u.discriminator}): #{tag.reply.substr(0,32)}..."
        msg.channel.sendMessage r

module.exports = TagModule

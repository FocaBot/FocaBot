class Announcements extends BotModule
  init: ->
    @registerCommand 'announce', { ownerOnly: true, argSeparator: '\n' }, ({ msg, args })=>
      if args.length > 1
        title = args[0]
        message = args.slice(1).join('\n').trim()
      else
        message = args[0]
      if msg.attachments.first()
        image = msg.attachments.first().url
      Core.shard.broadcastEval """
      Core.modules.loaded.announcements.announce(
        #{JSON.stringify(title)},
        #{JSON.stringify(message)},
        #{if image then JSON.stringify(image) else 'undefined'}
      )
      """
  
  announce: (title, message, image)->
    Core.bot.guilds.array().forEach (guild)=>
      try
        return if await Core.modules.isDisabledForGuild guild, @
        s = await Core.settings.getForGuild(guild)
        l = Core.locales.getLocale(s.locale)
        c = guild.defaultChannel
        try c = guild.channels.get(s.commandChannel) if s.commandChannel
        c.send embed: {
          title
          description: message
          color: 0x00AAFF
          image: if image then { url: image } else undefined
          footer:
            icon_url: Core.bot.user.displayAvatarURL
            text: l.gen(l.announcements.footer, "#{s.prefix}disable announcements")
        }

module.exports = Announcements

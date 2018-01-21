class Announcements extends BotModule
  init: ->
    @registerCommand 'announce', { ownerOnly: true, argSeparator: '\n' }, ({ msg, args })=>
      if args.length > 1
        title = args[0]
        message = args.slice(1).join('\n').trim()
      else
        message = args[0]
      # coffeelint: disable=max_line_length
      Core.shard.broadcastEval """
      Core.modules.loaded.announcements.announce(#{JSON.stringify(title)}, #{JSON.stringify(message)})
      """
      # coffeelint: enable=max_line_length
  
  announce: (title, message)->
    Core.bot.guilds.array().forEach (guild)=>
      try
        return if await Core.modules.isDisabledForGuild guild, @
        s = await Core.settings.getForGuild(guild)
        l = Core.locales.getLocale(s.locale)
        c = s.commandChannel or guild.defaultChannel
        c.send embed: {
          title
          description: message
          color: 0x00AAFF
          footer:
            icon_url: Core.bot.user.displayAvatarURL
            text: l.gen(l.announcements.footer, "#{s.prefix}disable announcements")
        }

module.exports = Announcements

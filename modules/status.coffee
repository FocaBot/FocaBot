class StatusModule extends BotModule
  ready: ->
    if Core.properties.debug
      Core.bot.user.setPresence status: 'dnd', game: name: Core.properties.version
    else
      Core.bot.user.setPresence {
        status: 'online'
        game: name: "#{Core.properties.prefix}help | focabot.xyz"
      }

module.exports = StatusModule

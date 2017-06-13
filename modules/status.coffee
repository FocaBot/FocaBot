class StatusModule extends BotModule
  ready: ->
    if Core.properties.debug
      Core.bot.user.setStatus 'dnd'
      Core.bot.user.setGame Core.properties.version
    else
      Core.bot.user.setStatus 'online'
      Core.bot.user.setGame "#{Core.properties.prefix}help | focabot.xyz"

module.exports = StatusModule

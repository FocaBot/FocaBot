moment = require 'moment'

class StatusModule extends BotModule
  ready: =>
    if Core.settings.debug
      Core.bot.User.setStatus 'dnd', "#{Core.settings.prefix}help | focabot.xyz"
    else
      Core.bot.User.setStatus 'online', Core.settings.version

module.exports = StatusModule

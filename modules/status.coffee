moment = require 'moment'

class StatusModule extends BotModule
  ready: =>
    if Core.settings.debug
      Core.bot.User.setStatus 'dnd', "f'help | focabot.xyz"
    else
      Core.bot.User.setStatus 'online', "f'help | focabot.xyz"

module.exports = StatusModule

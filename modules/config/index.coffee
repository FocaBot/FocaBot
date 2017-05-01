reload = require('require-reload')(require)
Commands = reload './commands'

# Configuration Manager
# Must be loaded before all standard modules.
class ConfigModule extends BotModule
  init: =>
    # Reset guild cache
    Core.guilds._guilds = {}
    # Set Defaults
    Core.guilds.Guild.defaultData = => {
      autoDel: true
      allowNSFW: false
      allowImages: true
      voteSkip: true
      restrict: false
      allowWaifus: true
      allowTags: true
      greet: 'off'
      farewell: 'off'
      maxSongLength: 1800 # 30 minutes
      dynamicNick: false
      maxItems: 0
      allowRNG: true
      raffleMention: false
      commandChannel: ''
      voiceChannel: '*'
      queueLoop: false
    }

    @cmd = new Commands @

module.exports = ConfigModule

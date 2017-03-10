# Configuration Manager
# Must be loaded before all standard modules.
Commands = require './commands'

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
    }

    @commands = new Commands @

module.exports = ConfigModule

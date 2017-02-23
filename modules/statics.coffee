moment = require 'moment'
os = require 'os'

class StatsModule extends BotModule
  init: =>
    @registerCommand 'stats', { allowDM: true }, (msg, args)=>
      mem = Math.floor process.memoryUsage().heapTotal / 1024000
      memfree = Math.floor os.freemem() / 1024000

      msg.channel.sendMessage '', false, {
        author:
          name: Core.settings.name + ' ' + Core.settings.version
          icon_url: Core.bot.User.avatarURL
        title: 'DEVELOPMENT BRANCH' if Core.settings.debug
        url: 'https://github.com/FocaBot/FocaBot'
        color: if Core.settings.debug then 0xFF3300 else 0x00AAFF
        fields: [
          {
            name: "Shard #{(Core.settings.shardIndex or 0)+1}/#{Core.settings.shardCount or 1}"
            value: """
            Uptime: #{Core.bootDate.fromNow(true)}
            Guilds: #{@bot.Guilds.length}
            Voice Connections: #{@bot.VoiceConnections.length}
            Memory: #{mem}MB (#{memfree}MB free)
            """
          }
          {
            name: 'FocaBotCore'
            value: """
            Version: #{Core.version}
            #{Object.keys(Core.modules.loaded).length} modules loaded.
            """
          }
        ]
      }

module.exports = StatsModule

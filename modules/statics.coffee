moment = require 'moment'
os = require 'os'

class StatsModule extends BotModule
  init: =>
    @registerCommand 'stats', { allowDM: true }, (msg, args)=>
      mem = Math.floor process.memoryUsage().heapTotal / 1024000
      memfree = Math.floor os.freemem() / 1024000
      loadAvg = os.loadavg().map((c)=> c.toFixed(2))
      totalCommands = Object.keys(Core.commands.plain).length
      excludingAliases = Object.keys(Core.commands.registered).length
      totalGuilds = 0
      totalVoice = 0

      # Get statics from the other shards
      stats = await Core.data.get('Stats')
      if stats?
        stats.forEach (shard)=>
          totalGuilds += shard.guilds
          totalVoice += shard.voice
      else
        # Fallback
        totalGuilds = @bot.Guilds.length
        totalVoice = @bot.VoiceConnections.length

      r = {
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
            **Uptime**: #{Core.bootDate.fromNow(true)}
            **Guilds**: #{@bot.Guilds.length}
            **Voice Connections**: #{@bot.VoiceConnections.length}
            **Memory Usage**: #{mem}MB
            """
          }
        ]
      }
      if Core.settings.shardCount
        r.fields.push {
          name: 'Overall'
          value: """
          **Guilds**: #{totalGuilds}
          **Voice Connections**: #{totalVoice}
          """
        }
      r.fields.push {
        name: 'System'
        value: """
        **Platform**: #{os.platform()} #{os.release()} #{os.arch()}
        **Load Average**: #{loadAvg}
        **Free Memory**: #{memfree}MB
        """
      }
      r.fields.push {
        name: 'FocaBotCore'
        value: """
        **Version**: #{Core.version}
        **Modules**: #{Object.keys(Core.modules.loaded).length} modules loaded.
        **Commands**: #{totalCommands} commands registered. \
        (#{totalCommands - excludingAliases} are aliases)
        """
      }
      msg.channel.sendMessage '', false, r

  updateStats: ->
    stats = (await Core.data.get('Stats')) or []
    stats[Core.settings.shardIndex or 0] = {
      guilds: Core.bot.Guilds.length
      voice: Core.bot.VoiceConnections.length
    }
    Core.data.set('Stats', stats)

  ready: =>
    @updateStats()
    Core.bot.Dispatcher.on('VOICE_CONNECTED', @updateStats)
    Core.bot.Dispatcher.on('VOICE_DISCONNECTED', @updateStats)
    Core.bot.Dispatcher.on('GUILD_CREATE', @updateStats)
    Core.bot.Dispatcher.on('GUILD_DELETE', @updateStats)


  unload: =>
    # Remove all listeners
    Core.bot.Dispatcher.removeListener('VOICE_CONNECTED', @updateStats)
    Core.bot.Dispatcher.removeListener('VOICE_DISCONNECTED', @updateStats)
    Core.bot.Dispatcher.removeListener('GUILD_CREATE', @updateStats)
    Core.bot.Dispatcher.removeListener('GUILD_DELETE', @updateStats)
    

module.exports = StatsModule

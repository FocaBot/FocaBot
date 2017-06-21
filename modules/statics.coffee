moment = require 'moment'
os = require 'os'

class StatsModule extends BotModule
  init: ->
    @registerCommand 'stats', { allowDM: true }, ({ msg, args, d })=>
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
        totalGuilds = Core.bot.guilds.array().length
        totalVoice = Core.bot.voiceConnections.array().length

      r = {
        author:
          name: Core.properties.name + ' ' + Core.properties.version
          icon_url: Core.bot.user.avatarURL
        title: 'DEBUG MODE ENABLED' if Core.properties.debug
        url: 'https://github.com/FocaBot/FocaBot'
        color: if Core.properties.debug then 0xFF3300 else 0x00AAFF
        fields: [
          {
            name: """
            Shard #{(Core.properties.shardIndex or 0)+1}/#{Core.properties.shardCount or 1}
            """
            value: """
            **Uptime**: #{Core.bootDate.fromNow(true)}
            **Guilds**: #{@bot.guilds.array().length}
            **Voice Connections**: #{@bot.voiceConnections.array().length}
            **Memory Usage**: #{mem}MB
            """
          }
        ]
      }
      if Core.properties.shardCount
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
        **Node Version**: #{process.version}
        **Load Average**: #{loadAvg}
        **Free Memory**: #{memfree}MB
        """
      }
      r.fields.push {
        name: 'Azarasi Framework'
        value: """
        **Version**: #{Core.version}
        **Modules**: #{Object.keys(Core.modules.loaded).length} modules loaded.
        **Commands**: #{totalCommands} commands registered. \
        (#{totalCommands - excludingAliases} are aliases)
        """
      }
      msg.channel.send '', embed: r

  updateStats: ->
    stats = (await Core.data.get('Stats')) or []
    stats[Core.properties.shardIndex or 0] = {
      guilds: Core.bot.guilds.array().length
      voice: Core.bot.voiceConnections.array().length
    }
    Core.data.set('Stats', stats)

  ready: ->
    @updateStats()
    @registerEvent 'discord.voiceStateUpdate', @updateStats
    @registerEvent 'discord.guildCreate', @updateStats
    @registerEvent 'discord.guildDelete', @updateStats
    

module.exports = StatsModule

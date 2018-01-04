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
      totalGuilds = @bot.guilds.size
      totalVoice = @bot.voiceConnections.size
      totalMem = mem

      # Get statics from the other shards
      stats = await Core.data.get('Stats')
      if stats?
        stats.forEach (shard)=>
          totalGuilds += shard.guilds
          totalVoice += shard.voice
      
      if Core.shard.count and Core.shard.count > 1
        # Count Guilds
        totalGuilds = (await Core.shard.fetchClientValues('guilds.size'))
        .reduce((total, guilds) -> total += guilds)
        # Count Voice Connections
        totalVoice = (await Core.shard.fetchClientValues('voiceConnections.size'))
        .reduce((total, voice) -> total += voice)
        # Total Memory usage
        totalMem = (await Core.shard.broadcastEval '''
        Math.floor(process.memoryUsage().heapTotal / 1024000)
        ''')
        .reduce((total, mem) -> total += mem)

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
            Shard #{(Core.shard.id or 0)+1}/#{Core.shard.count or 1}
            """
            value: """
            **Uptime**: #{Core.bootDate.fromNow(true)}
            **Guilds**: #{@bot.guilds.size}
            **Voice Connections**: #{@bot.voiceConnections.size}
            **Memory Usage**: #{mem}MB
            """
          }
        ]
      }
      if Core.shard.count and Core.shard.count > 1
        r.fields.push {
          name: 'Overall'
          value: """
          **Guilds**: #{totalGuilds}
          **Voice Connections**: #{totalVoice}
          **Memory Usage**: #{totalMem}MB
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

module.exports = StatsModule

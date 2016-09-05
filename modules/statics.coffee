moment = require 'moment'
os = require 'os'

class StatsModule extends BotModule
  init: =>
    @registerCommand 'stats', (msg, args)->
      uptime = moment().from @engine.bootDate, true
      mem = Math.floor process.memoryUsage().heapTotal / 1024000
      memfree = Math.floor os.freemem() / 1024000
      serverCount = @bot.Guilds.length
      reply = """
      **#{@engine.name} Stats**

      Current Version: #{@engine.version} (#{@engine.versionName})
      Platform: #{os.platform()} (#{os.arch()})
      Memory Usage: #{mem}MB (#{memfree}MB free)
      Load Average: #{JSON.stringify(os.loadavg())}
      Bot Uptime: #{uptime}

      Currently joined to #{serverCount} servers and #{@bot.VoiceConnections.length} voice channels.
      """
      msg.channel.sendMessage reply

module.exports = StatsModule

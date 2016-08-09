moment = require 'moment'
os = require 'os'

class StatsModule
  constructor: (@engine)->
    {@bot, @commands} = @engine
    # stats Command
    statsOptions =
      description: 'DIsplays statics about MIDIBot'
    @statsCommand = @commands.registerCommand 'stats', statsOptions, @statsCommandFunction

  statsCommandFunction: (msg, args)->
    uptime = moment().from @engine.bootDate, true
    mem = Math.floor process.memoryUsage().heapTotal / 1024000
    memfree = Math.floor os.freemem() / 1024000
    serverCount = @bot.servers.length
    reply = """
    **MIDIBot Statics**

    Current Version: #{@engine.version} (#{@engine.versionName})
    Platform: #{os.platform()} (#{os.arch()})
    Memory Usage: #{mem}MB (#{memfree}MB free)
    Load Average: #{JSON.stringify(os.loadavg())}
    Bot Uptime: #{uptime}
    
    Currently joined to #{serverCount} servers and #{@bot.voiceConnections.length} voice channels.
    """
    @bot.sendMessage msg.channel, reply

  shutdown: =>
    @commands.unregisterCommand @statsCommand

module.exports = StatsModule

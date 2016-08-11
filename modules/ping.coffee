class PingModule
  constructor: (@engine)->
    {@bot, @commands} = @engine
    # Ping Command
    pingOptions =
      description: 'Pong!'
    @pingCommand = @commands.registerCommand 'ping', pingOptions, @pingCommandFunction

  pingCommandFunction: (msg, args)->
    sd = Date.now()
    @bot.sendMessage msg.channel, "Pong!"
    .then (m)=> @bot.updateMessage m, "Pong! `#{Date.now() - sd}`"

  shutdown: =>
    @commands.unregisterCommand @pingCommand

module.exports = PingModule

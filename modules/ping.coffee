class PingModule
  constructor: (@engine)->
    {@bot, @commands} = @engine
    # Ping Command
    pingOptions =
      description: 'Pong!'
    @pingCommand = @commands.registerCommand 'ping', pingOptions, @pingCommandFunction

  pingCommandFunction: (msg, args)->
    @bot.sendMessage msg.channel, "Pong!"
    .then (m)=> @bot.updateMessage m, "Pong! `#{m.timestamp - msg.timestamp}ms`"

  shutdown: =>
    @commands.unregisterCommand @pingCommand

module.exports = PingModule

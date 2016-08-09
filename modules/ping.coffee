class PingModule
  constructor: (@engine)->
    {@bot, @commands} = @engine
    # Ping Command
    pingOptions =
      description: 'Pong!'
    @pingCommand = @commands.registerCommand 'ping', pingOptions, @pingCommandFunction

  pingCommandFunction: (msg, args)->
    @bot.reply msg, "Pong!"

  shutdown: =>
    @commands.unregisterCommand @pingCommand

module.exports = PingModule

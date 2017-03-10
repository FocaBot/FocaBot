class PingModule extends BotModule
  init: =>
    @registerCommand 'ping', { allowDM: true }, (msg, args)->
      # Get the current time
      originalDate = new Date(msg.timestamp).getTime()
      # Send a message and wait until it's sent
      m = await msg.channel.sendMessage '🏓 Pong!'
      # Update the message with the original time substracted from the current (ms)
      m.edit "🏓 Pong! `#{new Date(m.timestamp).getTime() - originalDate}ms`"

module.exports = PingModule

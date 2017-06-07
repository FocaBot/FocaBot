class PingModule extends BotModule
  init: =>
    @registerCommand 'ping', { allowDM: true }, ({ msg, args })->
      # Send a message and wait until it's sent
      pingMessage = await msg.channel.send '🏓 Pong!'
      # Update the message with the original time substracted from the current (ms)
      pingMessage.edit "🏓 Pong! `#{pingMessage.createdTimestamp - msg.createdTimestamp}ms`"

module.exports = PingModule

class PingModule extends BotModule
  init: =>
    @registerCommand 'ping', { allowDM: true }, (msg, args)->
      originalDate = new Date(msg.timestamp).getTime()
      m = await msg.channel.sendMessage '🏓 Pong!'
      m.edit "🏓 Pong! `#{new Date(m.timestamp).getTime() - originalDate}ms`"

module.exports = PingModule

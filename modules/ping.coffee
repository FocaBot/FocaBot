class PingModule extends BotModule
  init: =>  
    @registerCommand 'ping', (msg, args)->
      sd = new Date(msg.timestamp).getTime()
      msg.channel.sendMessage "Pong!"
      .then (m)=> m.edit "Pong! `#{new Date(m.timestamp).getTime() - sd}ms`"

module.exports = PingModule

class PingModule extends BotModule
  init: =>  
    @registerCommand 'ping', (msg, args)->
      sd = Date.now()
      msg.channel.sendMessage "Pong!"
      .then (m)=> m.edit "Pong! `#{Date.now() - sd}ms`"

module.exports = PingModule

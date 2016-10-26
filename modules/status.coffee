moment = require 'moment'

class StatusModule extends BotModule
  init: =>
    { @bot, @prefix } = @engine
    @statusList = [
      => "#{@prefix}help"
      => "#{@prefix}filters"
      => "music in #{@bot.VoiceConnections.length} servers!" if @bot.VoiceConnections.length
      => @engine.version if @engine.version.indexOf('dev') >= 0
      => if @engine.version.indexOf('dev') >= 0 then "with cutting-edge seals!" else "with seals!"
      => "#{moment().from @engine.bootDate, true} since last restart." if @engine.version.indexOf('dev') >= 0
    ]
    @int = setInterval =>
      @changeStatus()
    , 15000
    @changeStatus()

  changeStatus: =>
    newStatus = ''
    while not newStatus
      newStatus = @statusList[0]()
      @statusList.push @statusList.shift()
    sm = 'online'
    sm = 'dnd' if @engine.version.indexOf('dev') >= 0
    @bot.User.setStatus sm, newStatus

  beforeUnload: =>
    clearInterval @int

module.exports = StatusModule
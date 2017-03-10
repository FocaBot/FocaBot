moment = require 'moment'

class StatusModule extends BotModule
  init: =>
    { @bot, @bootDate } = @engine
    { @prefix, @debug, @version } = @engine.settings
    @statusList = [
      => "#{@prefix}help"
      => "#{@prefix}filters"
      => @version if @debug
      => if @debug then 'with cutting-edge seals!' else 'with seals!'
      => "#{@bootDate.fromNow(true)} since last restart." if @debug
      => "Shard #{(Core.settings.shardIndex or 0)+1}/#{Core.settings.shardCount or 1}" if @debug
    ]

  ready: =>
    @int = setInterval =>
      @changeStatus()
    , 30000
    @changeStatus()

  changeStatus: =>
    newStatus = ''
    while not newStatus
      newStatus = @statusList[0]()
      @statusList.push @statusList.shift()
    sm = 'online'
    sm = 'dnd' if @debug
    @bot.User.setStatus sm, newStatus

  unload: =>
    clearInterval @int

module.exports = StatusModule

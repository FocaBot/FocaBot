moment = require 'moment'

class StatusModule extends BotModule
  init: =>
    { @bot, @prefix } = @engine
    @statusList = [
      => ["#{@prefix}help"]
      => ["#{@prefix}filters"]
      => ["music in #{@bot.Guilds.length} servers!"] if @bot.Guilds.length
      => ["with seals!"]
      => [@engine.version] if @engine.version.indexOf('dev') >= 0
      => ["with cutting edge seals!"] if @engine.version.indexOf('dev') >= 0
      => ["#{moment().from @engine.bootDate, true} since last restart."] if @engine.version.indexOf('dev') >= 0
    ]
    @int = setInterval =>
      @changeStatus()
    , 15000
    @changeStatus()

  changeStatus: =>
    newStatus = ''
    while not newStatus
      newStatus = @statusList[0]
      @statusList.push @statusList.shift()
    sm = 'online'
    sm = 'dnd' if @engine.version.indexOf('dev') >= 0
    @bot.User.setStatus sm, {
      name: newStatus
    }

  beforeUnload: =>
    clearInterval @int

module.exports = StatusModule
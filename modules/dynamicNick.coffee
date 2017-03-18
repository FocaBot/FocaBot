# This should be included in the "player" module but i think it's a nice way
# to show how modules could access the player API
# NOTE: THIS MUST BE LOADED AFTER THE PLAYER MODULE
class DynamicNick extends BotModule
  ready: =>
    Core.modules.loaded.player.events.on('playing', @handlePlayback)
    Core.modules.loaded.player.events.on('paused', @handlePause)
    Core.modules.loaded.player.events.on('suspended', @handlePause)
    Core.modules.loaded.player.events.on('stopped', @handleStop)
    
  handlePlayback: ({ guild, guildData }, item)=>
    return unless guildData.data.dynamicNick
    Core.bot.User.memberOf(guild).setNickname("▶ | #{@getTitle(item)}")

  handlePause: ({ guild, guildData }, item)=>
    return unless guildData.data.dynamicNick
    Core.bot.User.memberOf(guild).setNickname("⏸ | #{@getTitle(item)}")

  handleStop: ({ guild, guildData })=>
    return unless guildData.data.dynamicNick
    Core.bot.User.memberOf(guild).setNickname(null)

  getTitle: (item)=>
    title = item.title.substr(0, 28)
    title = title.substr(0, 25) + '...' if item.title.length > 28
    title

  unload: =>
    Core.modules.loaded.player.events.removeListener('playing', @handlePlayback)
    Core.modules.loaded.player.events.removeListener('paused', @handlePause)
    Core.modules.loaded.player.events.removeListener('suspended', @handlePause)
    Core.modules.loaded.player.events.removeListener('stopped', @handleStop)

module.exports = DynamicNick

# This module makes use of the Player Module API, and should be
# loaded after the player module
class DynamicNick extends BotModule
  ready: =>
    { @events, @util } = Core.modules.loaded.player
    @events.on('end', @handleEnd)
    
  handleEnd: (player, item)=>
    return unless player.guildData.data.queueLoop
    # Fetch Video Info Again
    info = await @util.getInfo(item.sauce)
    # Ignore playlists
    return info.cancel() if info.partial
    # Add the item to the queue again
    player.queue.addItem {
      title: info.title
      requestedBy: item.requestedBy
      voiceChannel: item.voiceChannel
      textChannel: item.textChannel
      path: info.url
      sauce: info.webpage_url
      thumbnail: info.thumbnail
      radioStream: item.radioStream
      time: 0
      duration: item.duration
      filters: item.filters
    }, true, true
    
  unload: =>
    @events.removeListener('end', @handleEnd)

module.exports = DynamicNick

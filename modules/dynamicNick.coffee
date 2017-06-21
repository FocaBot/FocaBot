class DynamicNick extends BotModule
  ready: ->
    @registerEvent 'player.playing', ({ guild }, item)=>
      iC = '▶'
      iC = '📡' if not item.duration
      iC = '📻' if item.radioStream
      try guild.members.find('id', core.bot.user.id).setNickname("#{iC} | #{@getTitle(item)}")
    @registerEvent 'player.paused', ({ guild }, item)=>
      try guild.members.find('id', core.bot.user.id).setNickname("⏸ | #{@getTitle(item)}")
    @registerEvent 'player.suspended', ({ guild }, item)=>
      iC = '⏸'
      iC = '📡' if not item.duration
      iC = '📻' if item.radioStream
      try guild.members.find('id', core.bot.user.id).setNickname("#{iC} | #{@getTitle(item)}")
    @registerEvent 'player.stopped', ({ guild })=>
      try guild.members.find('id', core.bot.user.id).setNickname(null)

  getTitle: (item)->
    title = item.title.substr(0, 28)
    title = title.substr(0, 25) + '...' if item.title.length > 28
    title

module.exports = DynamicNick

class DynamicNick extends BotModule
  ready: ->
    @registerEvent 'player.playing', ({ guild }, item)=>
      try guild.members.find('id', core.bot.user.id).setNickname("▶ | #{@getTitle(item)}")
    @registerEvent 'player.paused', ({ guild }, item)=>
      try guild.members.find('id', core.bot.user.id).setNickname("⏸ | #{@getTitle(item)}")
    @registerEvent 'player.suspended', ({ guild }, item)=>
      try guild.members.find('id', core.bot.user.id).setNickname("⏸ | #{@getTitle(item)}")
    @registerEvent 'player.stopped', ({ guild })=>
      try guild.members.find('id', core.bot.user.id).setNickname(null)

  getTitle: (item)->
    title = item.title.substr(0, 28)
    title = title.substr(0, 25) + '...' if item.title.length > 28
    title

module.exports = DynamicNick

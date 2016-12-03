moment = require 'moment'
AudioModuleCommands = require './commands'
QueueManager = require './queueManager'
# AudioHud = require './hud'
# audioFilters = reload '../../filters'

prune = require 'json-prune'
format = require 'json-format'

class PlayerModule extends BotModule
  init: =>
    { @permissions } = @engine
    # @hud = new AudioHud @
    @moduleCommands = new AudioModuleCommands @
    @q = new QueueManager @
    { @parseTime } = Core.util

    @registerCommand 'playerdebug', (msg, args)=>
      queue = await @q.getForGuild msg.guild
      msg.channel.sendMessage '```json\n' + format(JSON.parse(prune(queue.data, 2)), {type:'space',size:2}) + '```'

  handleVideoInfo: (info, msg, args, gdata, silent=false)=>
    queue = await @q.getForGuild msg.guild
    duration = @parseTime info.duration

    queue.addToQueue({
      title: info.title
      duration
      requestedBy: msg.member
      voiceChannel: msg.member.getVoiceChannel()
      textChannel: msg.channel
      path: info.url
      sauce: info.webpage_url
      thumbnail: info.thumbnail
      filters: []
    })

module.exports = PlayerModule

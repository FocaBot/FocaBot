class QueueManager
  constructor: (@player)->
    { @engine } = @player
    @cached = {}

  getForGuild: (guild)=>
    return Promise.resolve @cached[guild.id] if @cached[guild.id]?
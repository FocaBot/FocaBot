EventEmitter = require 'events'

class AudioQueueInstance extends EventEmitter
  constructor: (data, @guildData)->
    @items = []
    @nowPlaying = {}
    @update data
    { @audioPlayer } = @guildData

  update: (@data)=> # Object.assign(@, @data)
    { @timestamp, @guildId, @updatedBy } = @data
    @nowPlaying = @data.nowPlaying or @nowPlaying
    @items = @data.items or @items
    deserializeItems = (i)=>
      i.requestedBy = Core.bot.Users.get(i.requestedBy).memberOf(@guildId) if i.requestedBy
      i.voiceChannel = Core.bot.Channels.get(i.voiceChannel) if i.voiceChannel
      i.textChannel = Core.bot.Channels.get(i.textChannel) if i.textChannel
    try
      deserializeItems @nowPlaying
    try
      deserializeItems item for item in @items

  addToQueue: (item)=>
    if item.path and item.voiceChannel
      @items.push(item)
      @emit 'updated'
      @nextItem() if not @nowPlaying or not @nowPlaying.path or not @nowPlaying.voiceChannel

  nextItem: =>
    if @nowPlaying
      @emit 'skipped', @nowPlaying
      @emit 'end', @nowPlaying
      @nowPlaying.skipped = true
      @audioPlayer.stop()
    @nowPlaying = @items.shift()
    if not @nowPlaying
      return @nextItem() if @items.length
      @audioPlayer.clean(true)
      @emit 'updated'
      return @emit 'end'
    @emit 'updated'
    @play @getFlags(@nowPlaying)

  play: (flags={}, offset, item=@nowPlaying)=>
    if not offset? and item.time
      offset = time
    else if not offset then offset = 0
    @audioPlayer.play item.voiceChannel, item.path, flags, offset
    .then (stream)=>
      @emit 'playing', item
      item.status = 'playing'
      stream.on 'end', ()=>
        @nextItem() if not item.skipped or item.status is 'paused'
        @emit 'end', item
      @emit 'start', item if offset is 0
    .catch (err)=> console.error err
    true

  getFlags: (item)=>
    return {} if not item.filters or item.filters.length
    flags = []; inputFlags = []; filters = []
    inRuntime = item.status isnt 'queue'

    for filter in item.filters
      continue if filter.avoidRuntime and inRuntime
      if filter.FFMPEGInputArgs
        inputFlags = inputFlags.concat filter.FFMPEGInputArgs
      else if filter.FFMPEGArgs
        flags = flags.concat filter.FFMPEGArgs
      else if filter.FFMPEGFilter
        filters.push filter.FFMPEGFilter
    flags.push '-af', filters.join ', '
    { input: inputFlags, output: flags }

  getTransformedTimestamp: (item, position, o=false)=>
    ts = position or item.originalDuration
    for filter in item.filters
      if o and filter.inverseModifier
        ts = Core.util.evalExpr filter.inverseModifier. ts
      else if filter.timeModifier
        ts = Core.util.evalExpr filter.timeModifier. ts
    ts

  updateFilters: (newFilters)=>
    @pause()
    @nowPlaying.filters = newFilters
    @nowPlaying.duration = @getTransformedTimestamp @nowPlaying
    @resume()
    @emit 'updated'

  pause: =>
    if @nowPlaying? and isFinite @nowPlaying.duration
      @nowPlaying.time = @getTransformedTimestamp @nowPlaying, @audioPlayer.getTimestamp(), true
      @nowPlaying.status = 'paused'
      @audioPlayer.stop()
      @emit 'updated'
      true
    else
      false

  resume: =>
    @play @getFlags(@nowPlaying), @nowPlaying.time
    @emit 'updated'

  seek: (newPos)=>
    newPos = @getTransformedTimestamp(@nowPlaying, newPos) if filterTransform
    # hacky way to "seek" is still hacky
    flags = @getFlags(@nowPlaying)
    if flags.input
      flags.input = flags.input.concat ['-ss', newPos]
    else flags.input = ['-ss', newPos]
    @pause()
    @playItem flags, @getTransformedTimestamp(@nowPlaying, newPos)

  undo: =>
    last = @items.pop()
    @emit 'removed', last
    return @nextItem() if not last and @nowPlaying
    @emit 'updated'

  remove: (index)=>
    return 'invalid' if not isFinite index or index >= @items.length
    item = @items.splice index, 1
    @emit 'removed', item
    @emit 'updated'

  swap: (ix1, ix2)=>
    return if not @items[ix1] or not @items[ix2]
    item1 = @items[ix1]
    @items[ix1] = @items[ix2]
    @items[ix2] = item1
    @emit 'updated'
    [ @items[ix1], @items[ix2] ]

  move: (ix, pos)=>
    return if ix >= @items.length or pos >= @items.length or ix < 0 or pos < 0
    @items.splice(pos, 0, @items.splice(ix, 1)[0])
    @emit 'updated'
    @items[pos]

  shuffle: =>
    @items = new Chance().shuffle(@items)
    @emit 'updated'

  clearQueue: =>
    @items = []
    @nextItem() if @nowPlaying? # same shit
    @emit 'updated'

module.exports = AudioQueueInstance
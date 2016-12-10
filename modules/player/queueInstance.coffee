EventEmitter = require 'events'
Chance = require 'chance'

class AudioQueueInstance extends EventEmitter
  constructor: (data, @guildData)->
    @update data
    { @audioPlayer } = @guildData

  update: (@data)=>
    { @timestamp, @guildId } = @data
    @nowPlaying = @data.nowPlaying
    @items = @data.items
    deserializeItems = (itm)=>
      return if not itm 
      if itm.forEach
        arr = []
        itm.forEach (i)=> arr.push(deserializeItems(i))
        arr
      else Object.assign({}, itm, {
        requestedBy: Core.bot.Users.get(itm.requestedBy).memberOf(@guildId) if itm.requestedBy
        voiceChannel: Core.bot.Channels.get(itm.voiceChannel) if itm.voiceChannel
        textChannel: Core.bot.Channels.get(itm.textChannel) if itm.textChannel
      })
    try
      @nowPlaying = deserializeItems(@nowPlaying)
      @items = deserializeItems(@items) or []
    catch e
      Core.log e

  addToQueue: (item)=>
    if item.path and item.voiceChannel
      item.originalDuration = item.duration
      item.duration = @getTransformedTimestamp(item)
      @items.push(item)
      @emit 'added', item
      @emit 'updated'
      @nextItem() if not @nowPlaying or not @nowPlaying.path or not @nowPlaying.voiceChannel

  nextItem: =>
    if @nowPlaying
      @nowPlaying.skipped = true
      @emit 'skipped', @nowPlaying
      @emit 'end', @nowPlaying
      @audioPlayer.stop()
    @nowPlaying = @items.shift()
    if not @nowPlaying
      return @nextItem() if @items.length
      @audioPlayer.clean(true)
      @emit 'updated'
      return @emit 'end'
    try
      await @play @getFlags(@nowPlaying)
      @emit 'updated'
    catch e
      Core.log e,2

  play: (flags={}, offset=0, item=@nowPlaying)=>
    stream = await @audioPlayer.play item.voiceChannel, item.path, flags, offset
    item.status = 'playing'
    @emit 'playing', item
    @emit 'start', item if offset is 0
    stream.on 'end', ()=>
      @nextItem() if not item.skipped or item.status is 'paused'
      @emit 'end', item

  getFlags: (item)=>
    return {} if not item.filters or not item.filters.length
    flags = []; inputFlags = []; filters = []
    inRuntime = item.status and item.status isnt 'queue'

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

  getTransformedTimestamp: (item, position=item.originalDuration, o=false)=>
    return position if not item.filters
    ts = position
    for filter in item.filters
      if o and filter.inverseTime
        ts = Core.util.evalExpr filter.inverseTime, ts
      else if filter.timeModifier
        ts = Core.util.evalExpr filter.timeModifier, ts
    return ts

  updateFilters: (item, newFilters)=>
    @pause() if item is @nowPlaying
    item.filters = newFilters
    item.duration = @getTransformedTimestamp item
    @resume() if item is @nowPlaying
    @emit 'updated'

  pause: =>
    if not @nowPlaying? or not isFinite(@nowPlaying.duration) or @nowPlaying.status is 'paused' or @nowPlaying.status is 'suspended'
      return false
    try
      @nowPlaying.time = @getTransformedTimestamp @nowPlaying, @audioPlayer.timestamp, true
    catch
      @nowPlaying.time = 0
    @nowPlaying.status = 'paused'
    @audioPlayer.stop()
    @emit 'updated'
    true

  resume: =>
    if not @nowPlaying? or not isFinite(@nowPlaying.duration) or @nowPlaying.status isnt 'paused'
      return false

    flags = @getFlags(@nowPlaying)
    if @nowPlaying.time isnt 0
      if flags.input
        flags.input = flags.input.concat ['-ss', @nowPlaying.time]
      else flags.input = ['-ss', @nowPlaying.time]
    await @play flags, @getTransformedTimestamp(@nowPlaying, @nowPlaying.time)
    @emit 'updated'

  seek: (newPos)=>
    if @pause()
      @nowPlaying.time = @getTransformedTimestamp(@nowPlaying, newPos, true)
      await @resume()
      true
    else false

  removeLast: ()=>
    last = @items.pop()
    @emit 'removed', last
    @emit 'updated'

  remove: (index)=>
    throw 'invalid' if not isFinite index or index >= @items.length
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
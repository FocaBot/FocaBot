Chance = require 'chance'

class GuildAudioQueueManager
  constructor: (@engine, @guild, @guildData)->
    {@bot, @permissions} = @engine
    {@audioPlayer} = @guildData
    @items = []

  addToQueue: (item)=>
    if item.path and item.playInChannel and typeof item.emit is 'function'
      @items.push(item)
      item.emit 'addedToQueue', @server
      if not @currentItem?
        @nextItem()

  nextItem: =>
    if @currentItem?
      @currentItem.emit 'skipped'
      @currentItem.emit 'end'
      @currentItem.skipped = true
      @audioPlayer.stop()
    item = @items.shift()
    @currentItem = item
    return false if not @currentItem?
    # Filters
    @playItem @getFlags(@currentItem)

  playItem: (flags={}, offset=0, item=@currentItem)=>
    @audioPlayer.play item.playInChannel, item.path, flags, offset
    .then (stream)=>
      stream.on 'end', ()=>
        @nextItem() if not item.skipped
        item.emit 'end'
      item.emit 'start' if offset is 0
    .catch (err)=>
      console.error err
      item.emit 'error', err
    true

  getFlags: (item, avoidRuntime)=>
    return {} if not item.filters.length
    flags = []
    inputFlags = []
    filters = []

    for filter in item.filters
      continue if avoidRuntime and filter.avoidRuntime
      if filter.toFFMPEGInputArgs
        inputFlags = inputFlags.concat filter.toFFMPEGInputArgs()
      else if filter.toFFMPEGArgs
        flags = flags.concat filter.toFFMPEGArgs()
      else if filter.toFFMPEGFilter
        filters.push filter.toFFMPEGFilter()
    
    flags.push '-af', filters.join ', '
    { input: inputFlags, output: flags }

  getTransformedTimestamp: (item, position, original=false)=>
    ts = position or item.originalDuration
    for filter in item.filters
      if original
        ts = filter.originalTime ts if filter.originalTime?
      else
        ts = filter.processTime ts if filter.processTime?
    ts

  updateFilters: (newFilters)=>
    if @currentItem? and isFinite @currentItem.duration # and newFilters.length 
      resumeAt = @getTransformedTimestamp @currentItem, @audioPlayer.getTimestamp(), true
      @currentItem.filters = newFilters
      @currentItem.duration = @getTransformedTimestamp @currentItem
      @seek resumeAt # without this, the new filters won't be applied!

  seek: (newPos, filterTransform=false)=>
    # console.log newPos, @currentItem
    newPos = @getTransformedTimestamp(@currentItem, newPos) if filterTransform
    # hacky way to "seek"
    flags = @getFlags(@currentItem)
    if flags.input
      flags.input = flags.input.concat ['-ss', newPos]
    else flags.input = ['-ss', newPos]
    @currentItem.skipped = true
    @audioPlayer.stop()
    @playItem flags, @getTransformedTimestamp(@currentItem, newPos)
    @currentItem.skipped = false

  undo: =>
    last = @items.pop()
    return @nextItem() if not last and @currentItem
    last.skipped = true
    last.undone = true
    last.emit 'undone'
    last.emit 'end'

  remove: (index)=>
    return 'invalid' if not isFinite index or index >= @items.length
    item = @items.splice index, 1
    item.skipped = true
    item.undone = true
    item.emit 'undone'
    item.emit 'end'

  swap: (ix1, ix2)=>
    item1 = @items[ix1]
    @items[ix1] = @items[ix2]
    @items[ix2] = item1
    [ @items[ix1], @items[ix2] ]

  shuffle: => @items = new Chance().shuffle(@items)

  clearQueue: =>
    for item in @items
      @items.shift()
      try
        item.emit 'skipped'
        item.skipped = true
    if @currentItem?
      @currentItem.skipped = true
      @currentItem.emit 'skipped'
      @currentItem.emit 'end'
      @currentItem = null
    @audioPlayer.stop()

module.exports = GuildAudioQueueManager

Chance = require 'chance'

class GuildAudioQueueManager
  constructor: (@engine, @guild)->
    {@bot, @permissions, @getGuildData} = @engine
    {@audioPlayer} = @getGuildData @guild
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
      @currentItem.skipped = true
      @audioPlayer.stop()
    item = @items.shift()
    @currentItem = item
    return false if not @currentItem?
    # Filters
    if @currentItem.filters.length
      flags = ['-filter']
      filters = []
      filters.push filter.toFFMPEGFilter() for filter in @currentItem.filters
      flags.push filters.join ', '
    else flags = []
    @audioPlayer.play @currentItem.playInChannel, @currentItem.path, flags
    .then (stream)=>
      stream.on 'end', ()=>
        @nextItem() if not item.skipped
        item.emit 'end'
      item.emit 'start'
    .catch (err)=>
      console.error err
      item.emit 'error', err
    true

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
      item.emit 'skipped'
      item.skipped = true
    if @currentItem?
      @currentItem.emit 'skipped'
      @currentItem.skipped = true
      @currentItem = null
    @audioPlayer.stop()

module.exports = GuildAudioQueueManager

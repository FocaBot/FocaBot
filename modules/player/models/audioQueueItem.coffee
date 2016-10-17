EventEmitter = require 'events'
moment = require 'moment'

class QueueItem extends EventEmitter
  constructor: (data)->
    {
       @title,
       @duration,
       @requestedBy,
       @playInChannel,
       @filters,
       @path,
       @sauce,
       @thumbnail,
    } = data
    @state = 'queued'
    @voteSkip = []
    @originalDuration = @duration
    for filter in @filters
      @duration = filter.processTime @duration if filter.processTime
    

module.exports = QueueItem

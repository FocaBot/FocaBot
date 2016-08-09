EventEmitter = require 'events'

class QueueItem extends EventEmitter
  constructor: (data)->
    {
       @title,
       @duration,
       @requestedBy,
       @playInChannel,
       @filters,
       @path,
    } = data

module.exports = QueueItem

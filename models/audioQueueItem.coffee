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
    } = data
    @voteSkip = []
    for filter in @filters
      @duration = filter.processTime @duration if filter.processTime
    t = @duration.split(':').reverse()
    m = moment.duration {
      seconds: t[0]
      minutes: t[1]
      hours: t[2]
    }
    @duration = "#{@padTime m.minutes()}:#{@padTime m.seconds()}"

  padTime:(str)=> ('00'+str).substr str.toString().length

module.exports = QueueItem

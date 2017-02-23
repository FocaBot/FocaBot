AudioFilter = require './base'

class ReverseFilter extends AudioFilter
  constructor: ->
    super()
    @name = 'reverse'
    @display = '[Reversed]'
    @FFMPEGFilter = 'areverse'
    @avoidRuntime = true

module.exports = ReverseFilter

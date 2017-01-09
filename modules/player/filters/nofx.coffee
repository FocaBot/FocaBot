AudioFilter = require './base'

class NoFilter extends AudioFilter
  constructor:->
    super
    @display = "[NOFX]"
    @name = "nofx"
    @avoidRuntime = true
  
module.exports = NoFilter

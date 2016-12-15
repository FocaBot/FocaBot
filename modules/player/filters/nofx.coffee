AudioFilter = require './base'

class NoFilter extends AudioFilter
  constructor:->
    @display = "[NOFX]"
    @name = "nofx"
    @avoidRuntime = true
  
module.exports = NoFilter

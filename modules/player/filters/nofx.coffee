AudioFilter = require './base'

class NoFilter extends AudioFilter
  constructor:->
    @name = "[NOFX]"
    @avoidRuntime = true
  
module.exports = NoFilter

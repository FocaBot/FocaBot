AudioFilter = require './base'

class NoFilter extends AudioFilter
  name: "[NOFX]"
  avoidRuntime: true
  
module.exports = NoFilter

AudioFilter = require '../models/audioFilter'

class NoFilter extends AudioFilter
  name: "[NOFX]"
  avoidRuntime: true
  
module.exports = NoFilter

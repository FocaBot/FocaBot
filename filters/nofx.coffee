AudioFilter = require '../models/audioFilter'

class NoFilter extends AudioFilter
  toString:=> "[NOFX]"
  avoidRuntime: true
  
module.exports = NoFilter

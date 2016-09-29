AudioFilter = require '../models/audioFilter'

class NoFilter extends AudioFilter
  toString:=> "[NOFX]"
  validate:=> true
  avoidRuntime: true
  
module.exports = NoFilter

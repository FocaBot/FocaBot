AudioFilter = require '../models/audioFilter'

class NoFilter extends AudioFilter
  toString:=> "[NOFX]"
  toFFMPEGFilter:=> "anull"
  avoidRuntime: true
  
module.exports = NoFilter

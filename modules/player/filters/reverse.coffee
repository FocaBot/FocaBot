AudioFilter = require '../models/audioFilter'

class ReverseFilter extends AudioFilter
  toFFMPEGFilter:=> 'areverse'
  toString:=> "[Reversed]"
  avoidRuntime: true
  
module.exports = ReverseFilter

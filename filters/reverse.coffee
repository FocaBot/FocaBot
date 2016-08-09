AudioFilter = require '../models/audioFilter'

class ReverseFilter extends AudioFilter
  toFFMPEGFilter:=> 'areverse'
  toString:=> "[Reversed]"
  
module.exports = ReverseFilter

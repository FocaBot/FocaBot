AudioFilter = require '../models/audioFilter'

class KaraokeFilter extends AudioFilter
  toFFMPEGFilter:=> 'stereotools=mlev=0.015625'
  toString:=> "[Karaoke]"
  
module.exports = KaraokeFilter

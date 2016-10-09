AudioFilter = require '../models/audioFilter'

class KaraokeFilter extends AudioFilter
  toFFMPEGFilter:=> 'bandreject=f=900:width_type=h:w=600'
  toString:=> "[Karaoke]"
  
module.exports = KaraokeFilter

AudioFilter = require '../models/audioFilter'

class PhaserFilter extends AudioFilter
  toFFMPEGFilter:=> 'aphaser=type=s'
  toString:=> "[Phaser]"
  
module.exports = PhaserFilter

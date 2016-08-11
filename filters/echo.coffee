AudioFilter = require '../models/audioFilter'

class EchoFilter extends AudioFilter
  toFFMPEGFilter:=> 'aecho=0.8:0.9:1000|1800:0.3|0.25'
  toString:=> "[Echo]"
  
module.exports = EchoFilter

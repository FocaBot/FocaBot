AudioFilter = require '../models/audioFilter'

class LowPassFilter extends AudioFilter
  validate:=>
    frq = parseInt @param or 3000
    return 'Requested frequency is not a number.' if not frq
    return 'Frequency must not be higher than 50000' if frq > 50000
    return 'Frequency must not be lower than 100' if frq < 100

  toFFMPEGFilter:=> @escape "lowpass=f=#{parseInt(@param) or 3000}"
  toString:=> "[LowPass]"
  
module.exports = LowPassFilter
AudioFilter = require '../models/audioFilter'

class BassFilter extends AudioFilter
  validate:=>
    gain = parseInt @param or 2
    return 'Requested gain is not a number.' if not gain
    return 'Gain must not be higher than 20' if gain > 20
    return 'Gain must not be lower than -20' if gain< -20

  toFFMPEGFilter:=> @escape "bass=g=#{parseInt(@param) or 2}"
  toString:=> "[Bass #{@param}]"
  isAdminOnly:=> true
  
module.exports = BassFilter
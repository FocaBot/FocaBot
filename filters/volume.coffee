AudioFilter = require '../models/audioFilter'

class ReverseFilter extends AudioFilter
  validate:=>
    volume = parseFloat @param 
    return 'Requested volume is not a number.' if not volume
    return 'Volume must not be higher than 40' if volume > 40
    return 'Volume must not be lower than -40' if volume < -40

  toFFMPEGFilter:=> "volume=#{parseFloat(@param)}dB"
  toString:=> "[#{@param}dB]"
  isAdminOnly:=> true
  
module.exports = ReverseFilter

AudioFilter = require '../models/audioFilter'

class FlangerFilter extends AudioFilter
  validate:=>
    speed = parseFloat @param or 0.5
    return 'Requested speed is not a number.' if not speed
    return 'Speed must not be higher than 10' if speed > 10
    return 'Speed must not be lower than 0.1' if speed < 0.1

  toFFMPEGFilter:=> @escape "flanger=speed=#{parseFloat(@param)}"
  toString:=> "[Flanger #{@param}]"
  
module.exports = FlangerFilter
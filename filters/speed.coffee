AudioFilter = require '../models/audioFilter'

class SpeedFilter extends AudioFilter
  validate:=>
    speed = parseFloat @param 
    return 'Requested speed is not a number.' if not speed
    return 'Speed must not be higher than 4' if speed > 4
    return 'Speed must not be lower than 0.25' if speed < 0.25

  toFFMPEGFilter:=> @escape "asetrate=#{44100 * parseFloat(@param)}"
  toString:=> "[#{@param}x Speed]"
  
module.exports = SpeedFilter
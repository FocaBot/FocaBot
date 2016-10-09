AudioFilter = require '../models/audioFilter'
moment = require 'moment'

class TempoFilter extends AudioFilter
  processTime: (time)=> time / parseFloat(@param)
  originalTime: (time)=> time * parseFloat(@param)

  validate:=>
    speed = parseFloat @param 
    return 'Requested speed is not a number.' if not speed
    return 'Speed must not be higher than 2' if speed > 2
    return 'Speed must not be lower than 0.5' if speed < 0.5
    
  toFFMPEGFilter:=> @escape "atempo=#{parseFloat(@param)}"
  toString:=> "[#{@param}x Tempo]"
  
module.exports = TempoFilter
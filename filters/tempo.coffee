AudioFilter = require '../models/audioFilter'
moment = require 'moment'

class TempoFilter extends AudioFilter
  parseTime:(time)=>
    t = time.split(':').reverse()
    moment.duration {
      seconds: t[0]
      minutes: t[1]
      hours:   t[2]
    }
    .asSeconds()

  parseTimestamp: (time)=>
    t = moment.duration { seconds: time }
    "#{t.minutes()}:#{t.seconds()}"

  processTime: (time)=>
    originalTime = @parseTime time
    return @parseTimestamp originalTime / parseFloat(@param)

  validate:=>
    speed = parseFloat @param 
    return 'Requested speed is not a number.' if not speed
    return 'Speed must not be higher than 4' if speed > 4
    return 'Speed must not be lower than 0.25' if speed < 0.25
    
  toFFMPEGFilter:=> @escape "atempo=#{parseFloat(@param)}"
  toString:=> "[#{@param}x Tempo]"
  
module.exports = TempoFilter
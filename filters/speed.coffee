AudioFilter = require '../models/audioFilter'
moment = require 'moment'

class SpeedFilter extends AudioFilter
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
    return 'Speed must not be higher than 10' if speed > 10
    return 'Speed must not be lower than 0.1' if speed < 0.1

  toFFMPEGFilter:=> @escape "asetrate=#{44100 * parseFloat(@param)}"
  toString:=> "[#{@param}x Speed]"
  
module.exports = SpeedFilter
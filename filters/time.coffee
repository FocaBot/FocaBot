AudioFilter = require '../models/audioFilter'
moment = require 'moment'

class TimeFilter extends AudioFilter
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
    return @parseTimestamp @e if @e
    return @parseTimestamp originalTime - @s if @s

  validate:=>
    splt = @param.split '-'
    start = splt[0]
    end = splt[1]
    valid = false
    if start
      @s = @parseTime start
      valid = true
      return 'Invalid start timestamp.' if not @s
    if end
      @e = @parseTime end
      valid = true
      return 'Invalid duration timestamp.' if not @e 
    return 'Invalid format.' if not valid

  toFFMPEGFilter:=>
    flt = 'atrim='
    fla = []
    fla.push "start=#{@s}" if @s 
    fla.push "duration=#{@e}" if @e
    flt += fla.join ':'
    @escape flt

  toString:=> 
    r = '[Time]'
    r = '' if @s or @e
    r += "[From #{@s}s]" if @s
    r += " [Duration #{@e}s]" if @e
    r
    
  
module.exports = TimeFilter
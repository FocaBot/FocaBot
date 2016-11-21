AudioFilter = require '../models/audioFilter'
moment = require 'moment'

class LoopFilter extends AudioFilter
  parseTime:(time)=>
    t = time.split(':').reverse()
    moment.duration {
      seconds: t[0]
      minutes: t[1]
      hours:   t[2]
    }
    .asSeconds()

  processTime: (time)=>
    return time + (@length * @loops)

  validate:=>
    splt = @param.split '-'
    @start = @parseTime(splt[0])
    @length = @parseTime(splt[1]) - @start
    @loops = splt[2]
    if (not @start and @start isnt 0) or not @length or not @loops or @end < 0
      return 'Invalid filter syntax. You have to specify start-end-loops (example: `loop=0:15-0:45-5`)'
      

  toFFMPEGFilter:=> @escape "aloop=loop=#{@loops}:size=#{@length * 48000}:start=#{@start*48000}"

  toString:=> 
    r = "[Looped from #{@start}s to #{@length + @start}s #{@loops} times]"

  avoidRuntime: true
    
  
module.exports = LoopFilter
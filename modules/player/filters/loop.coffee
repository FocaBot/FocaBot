AudioFilter = require './base'
{ permissions } = Core
{ parseTime } = Core.util

class LoopFilter extends AudioFilter
  constructor: (@param, member, playing, filters)->
    @name = 'loop'
    @display = '[Loop]'
    @avoidRuntime = true

    throw "[Loop] Not enough permissions to use this filter" if not permissions.isDJ member
    for filter in filters
      throw "You can't use this filter twice." if filter.name is 'loop'
    splt = @param.split '-'
    @start = parseTime(splt[0])
    @length = parseTime(splt[1]) - @start
    @loops = splt[2]
    if (not @start and @start isnt 0) or not @length or not @loops or @length < 0
      throw '[Loop] Invalid filter syntax. You have to specify start-end-loops (example: `loop=0:15-0:45-5`)'
    @FFMPEGFilter = @escape "aloop=loop=#{@loops}:size=#{@length * 48000}:start=#{(@start*48000) or 0}"
    @display = "[Looped from #{@start}s to #{@length + @start}s #{@loops} times]"
    @timeModifier = "{n} + (#{@length}*#{@loops})"
    @inverseTime = "0"
  
module.exports = LoopFilter

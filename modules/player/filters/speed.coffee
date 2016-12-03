AudioFilter = require './base'

class SpeedFilter extends AudioFilter
  name: 'speed'
  display: '[Speed]'

  constructor: (@param, member, playing, filters)->
    for filter in filters
      return "You can't use this filter twice." if filter.name is 'speed'
    @speed = parseFloat(@param)
    return 'Requested speed is not a number.' if not speed
    return 'Speed must not be higher than 10' if @speed > 10
    return 'Speed must not be lower than 0.1' if @speed < 0.1
    @FFMPEGFilter = @escape "asetrate=#{48000 * @speed}"
    @display = "[#{@speed}x]"
    @timeModifier = "{n} / #{@speed}"
    @inverseTime = "{n} * #{@speed}"
    true
  
module.exports = SpeedFilter
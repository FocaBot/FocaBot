AudioFilter = require './base'

class TempoFilter extends AudioFilter
  name: 'tempo'
  display: '[Tempo]'

  constructor: (@param, member, playing, filters)->
    super
    @speed = parseFloat(@param)
    return 'Requested speed is not a number.' if not speed
    return 'Speed must not be higher than 2' if @speed > 2
    return 'Speed must not be lower than 0.5' if @speed < 0.5
    @FFMPEGFilter = @escape "atempo=#{@speed}"
    @display = "[#{@speed}x Tempo]"
    @timeModifier = "{n} / #{@speed}"
    @inverseTime = "{n} * #{@speed}"
    true
  
module.exports = TempoFilter
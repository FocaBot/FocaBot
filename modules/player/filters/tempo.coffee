AudioFilter = require './base'

class TempoFilter extends AudioFilter
  constructor: (@param, member, playing, filters)->
    @name = 'tempo'
    @display = '[Tempo]'

    @speed = parseFloat(@param)
    throw '[Tempo] Requested speed is not a number.' if not @speed
    throw '[Tempo] Speed must not be higher than 2' if @speed > 2
    throw '[Tempo] Speed must not be lower than 0.5' if @speed < 0.5
    @FFMPEGFilter = @escape "atempo=#{@speed}"
    @display = "[#{@speed}x Tempo]"
    @timeModifier = "{n} / #{@speed}"
    @inverseTime = "{n} * #{@speed}"
  
module.exports = TempoFilter
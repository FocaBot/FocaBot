AudioFilter = require './base'

class FlangerFilter extends AudioFilter
  name: 'flanger'
  display: '[Flanger]'

  constructor: (@param)->
    @speed = parseFloat(@param) or 0.5
    throw 'Speed must not be higher than 10' if @speed > 10
    throw 'Speed must not be lower than 0.1' if @speed < 0.1
    @FFMPEGFilter = @escape "flanger=speed=#{@speed}"
    @display = "[Flanger #{@speed}]"
  
module.exports = FlangerFilter
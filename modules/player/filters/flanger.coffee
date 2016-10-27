AudioFilter = require './base'

class FlangerFilter extends AudioFilter
  name: 'flanger'

  constructor: (@param)->
    super
    @display = '[Flanger]'
    @speed = parseFloat(@param) or 0.5
    return 'Speed must not be higher than 10' if @speed > 10
    return 'Speed must not be lower than 0.1' if @speed < 0.1
    @FFMPEGFilter = @escape "flanger=speed=#{@speed}"
    @display = "[Flanger #{@speed}]"
    true
  
module.exports = FlangerFilter
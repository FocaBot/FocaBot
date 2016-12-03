AudioFilter = require './base'

class LowPassFilter extends AudioFilter
  name: 'lowpass'
  display: '[LowPass]'
  
  constructor: (@param)->
    @frq = parseInt(@param) or 1015
    return 'Frequency must not be higher than 50000' if @frq > 50000
    return 'Frequency must not be lower than 100' if @frq < 100
    @FFMPEGFilter = @escape "lowpass=f=#{@frq}"
    @display = "[LowPass@#{@frq}Hz]"
    true
  
module.exports = LowPassFilter
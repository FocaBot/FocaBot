AudioFilter = require './base'

class HighPassFilter extends AudioFilter
  name: 'highpass'
  display: '[HighPass]'

  constructor: (@param)->
    @name = 'highpass'
    @frq = parseInt(@param) or 1015
    return 'Frequency must not be higher than 50000' if @frq > 50000
    return 'Frequency must not be lower than 100' if @frq < 100
    @FFMPEGFilter = @escape "highpass=f=#{@frq}"
    @display = "[HighPass@#{@frq}Hz]"
    true
  
module.exports = HighPassFilter
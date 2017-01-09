AudioFilter = require './base'

class HighPassFilter extends AudioFilter
  constructor: (param)->
    super
    @param = param
    @name = 'highpass'
    @display = '[HighPass]'

    @name = 'highpass'
    @frq = parseInt(@param) or 1015
    throw '[HighPass] Frequency must not be higher than 50000' if @frq > 50000
    throw '[HighPass] Frequency must not be lower than 100' if @frq < 100
    @FFMPEGFilter = @escape "highpass=f=#{@frq}"
    @display = "[HighPass@#{@frq}Hz]"
  
module.exports = HighPassFilter
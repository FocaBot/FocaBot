AudioFilter = require './base'

class LowPassFilter extends AudioFilter
  constructor: (@param)->
    super()
    @name = 'lowpass'
    @display = '[LowPass]'

    @frq = parseInt(@param) or 1015
    throw '[LowPass] Frequency must not be higher than 50000' if @frq > 50000
    throw '[LowPass] Frequency must not be lower than 100' if @frq < 100
    @FFMPEGFilter = @escape "lowpass=f=#{@frq}"
    @display = "[LowPass@#{@frq}Hz]"

module.exports = LowPassFilter

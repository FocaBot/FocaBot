AudioFilter = require './base'

class SpeedFilter extends AudioFilter
  constructor: (param, member, playing, filters)->
    super
    @param = param
    @name = 'speed'
    @display = '[Speed]'

    for filter in filters
      throw "[Speed] You can't use this filter twice." if filter.name is 'speed'
    @speed = parseFloat(@param)
    throw '[Speed] Requested speed is not a number.' if not @speed
    throw '[Speed] Speed must not be higher than 10' if @speed > 10
    throw '[Speed] Speed must not be lower than 0.1' if @speed < 0.1
    @FFMPEGFilter = @escape "asetrate=#{48000 * @speed}"
    @display = "[#{@speed}x]"
    @timeModifier = "{n} / #{@speed}"
    @inverseTime = "{n} * #{@speed}"
  
module.exports = SpeedFilter
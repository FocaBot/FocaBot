AudioFilter = require './base'
{ permissions } = Core

class VolumeFilter extends AudioFilter
  constructor: (@param, member)->
    super()
    @name = 'volume'
    @display = '[Volume]'
    throw '[Volume] Not enough permissions to use this filter' unless permissions.isDJ(member)
    @gain = parseFloat(@param) or 2
    throw '[Volume] Gain must not be higher than 40' if @gain > 40
    throw '[Volume] Gain must not be lower than -40' if @gain< -40
    @FFMPEGFilter = @escape "volume=#{@gain}dB"
    @display = "[#{@gain}dB]"
    true

module.exports = VolumeFilter

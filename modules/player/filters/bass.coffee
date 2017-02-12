AudioFilter = require './base'
{ permissions } = Core

class BassFilter extends AudioFilter
  constructor: (@param, member)->
    super()
    @name = 'bass'
    @display = '[Bass]'

    throw "[Bass] Not enough permissions to use this filter" if not permissions.isDJ member
    @gain = parseInt(@param) or 2
    throw '[Bass] Gain must not be higher than 20' if @gain > 20
    throw '[Bass] Gain must not be lower than -20' if @gain< -20
    @FFMPEGFilter = @escape "bass=g=#{@gain}"
    @display = "[#{@gain}x Bass]"

module.exports = BassFilter

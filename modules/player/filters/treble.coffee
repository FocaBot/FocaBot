AudioFilter = require './base'
{ permissions } = Core

class TrebleFilter extends AudioFilter
  constructor: (@param, member)->
    super()
    @name = 'treble'
    @display = '[Treble]'

    throw '[Treble] Not enough permissions to use this filter' unless permissions.isDJ(member)
    @gain = parseInt(@param) or 2
    throw '[Treble] Gain must not be higher than 20' if @gain > 20
    throw '[Treble] Gain must not be lower than -20' if @gain< -20
    @FFMPEGFilter = @escape "treble=g=#{@gain}"
    @display = "[#{@gain}x Treble]"

module.exports = TrebleFilter

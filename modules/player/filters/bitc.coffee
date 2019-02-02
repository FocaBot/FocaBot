AudioFilter = require './base'
{ permissions } = Core

class BitCrushFilter extends AudioFilter
  constructor: (@param, member)->
    super()
    @name = 'bitc'
    @display = '[Bit Crusher]'

    throw '[Bit Crusher] Not enough permissions to use this filter' unless permissions.isDJ(member)
    @samples = parseFloat(@param) or 10
    throw '[Bit Crusher] Sample reduction must not be higher than 250' if @samples > 250
    throw '[Bit Crusher] Sample reduction must not be lower than 1' if @samples < 1
    @FFMPEGFilter = @escape "acrusher=bits=8:mix=1:samples=#{@samples}"
    @display = "[BitC@#{@samples}]"

module.exports = BitCrushFilter

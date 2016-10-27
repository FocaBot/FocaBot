AudioFilter = require './base'

class TremoloFilter extends AudioFilter
  name: 'tremolo'
  
  constructor: (@param)->
    super
    @display = '[Tremolo]'
    @ratio = parseFloat(@param) or 0.5
    return 'Ratio must not be higher than 20000' if @ratio > 20000
    return 'Ratio must not be lower than 0.1' if @ratio < 0.1
    @FFMPEGFilter = @escape "tremolo=d=0.8:f=#{@ratio}"
    @display = "[Tremolo #{@ratio}]"
    true
  
module.exports = TremoloFilter
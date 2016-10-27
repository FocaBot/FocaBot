AudioFilter = require './base'

class DistortFilter extends AudioFilter
  name: 'distort'
  display: '[Distort]'
  
  constructor: (@param)->
    super
    @ratio = parseFloat(@param) or 5
    return 'Ratio must not be higher than 20000' if @ratio > 20000
    return 'Ratio must not be lower than 0.1' if @ratio < 0.1
    @FFMPEGFilter = @escape "vibrato=d=1:f=#{@ratio}"
    @display = "[Distort x#{@ratio}]"
    true
  
module.exports = DistortFilter
AudioFilter = require './base'

class DistortFilter extends AudioFilter
  constructor: (param)->
    super
    @param = param
    @name = 'distort'
    @display = '[Distort]'
    
    @ratio = parseFloat(@param) or 5
    throw '[Distort] Ratio must not be higher than 20000' if @ratio > 20000
    throw '[Distort] Ratio must not be lower than 0.1' if @ratio < 0.1
    @FFMPEGFilter = @escape "vibrato=d=1:f=#{@ratio}"
    @display = "[Distort x#{@ratio}]"
  
module.exports = DistortFilter
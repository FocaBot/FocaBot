AudioFilter = require './base'
{ isDJ } = Core.permissions

class BassFilter extends AudioFilter
  name: 'bass'
  display: '[Bass]'
  
  constructor: (@param, member)->
    throw "[Bass] Not enough permissions to use this filter" if not isDJ member
    @gain = parseInt(@param) or 2
    throw '[Bass] Gain must not be higher than 20' if gain > 20
    throw '[Bass] Gain must not be lower than -20' if gain< -20
    @FFMPEGFilter = @escape "bass=g=#{@gain}"
    @display = "[#{@gain}x Bass]"
  
module.exports = BassFilter
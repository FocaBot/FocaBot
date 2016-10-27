AudioFilter = require './base'

class ReverseFilter extends AudioFilter
  name: 'reverse'
  display: '[Reversed]'
  FFMPEGFilter: 'areverse'
  avoidRuntime: true
  
module.exports = ReverseFilter
AudioFilter = require './base'

class ReverseFilter extends AudioFilter
  name: 'reverse'
  display: '[Reversed]'
  FFMPEGFilter: 'areverse'
  
module.exports = ReverseFilter
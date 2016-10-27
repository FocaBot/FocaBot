AudioFilter = require './base'

class ChorusFilter extends AudioFilter
  name: 'chorus'
  display: '[Chorus]'
  FFMPEGFilter: 'chorus=0.5:0.9:50|60|40:0.4|0.32|0.3:0.25|0.4|0.3:2|2.3|1.3'
  
module.exports = ChorusFilter
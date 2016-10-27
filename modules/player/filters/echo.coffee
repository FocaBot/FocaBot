AudioFilter = require './base'

class EchoFilter extends AudioFilter
  name: 'echo'
  display: '[Echo]'
  FFMPEGFilter: 'aecho=0.8:0.9:1000|1800:0.3|0.25'
  
module.exports = EchoFilter
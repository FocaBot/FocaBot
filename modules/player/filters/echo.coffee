AudioFilter = require './base'

class EchoFilter extends AudioFilter
  constructor:->
    @name = 'echo'
    @display = '[Echo]'
    @FFMPEGFilter = 'aecho=0.8:0.9:1000|1800:0.3|0.25'
    @timeModifier = '{n} + 2'
  
module.exports = EchoFilter
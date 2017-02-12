AudioFilter = require './base'

class PhaserFilter extends AudioFilter
  constructor:->
    super()
    @name = 'phaser'
    @display = '[Phaser]'
    @FFMPEGFilter = 'aphaser=type=s'

module.exports = PhaserFilter

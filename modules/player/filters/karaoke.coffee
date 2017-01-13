AudioFilter = require './base'

class KaraokeFilter extends AudioFilter
  constructor:->
    @name = 'karaoke'
    @display = '[Karaoke]'
    @FFMPEGFilter = 'stereotools=mlev=0.015625'
  
module.exports = KaraokeFilter
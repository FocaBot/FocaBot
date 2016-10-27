AudioFilter = require './base'

class KaraokeFilter extends AudioFilter
  name: 'karaoke'
  display: '[Karaoke]'
  FFMPEGFilter: 'stereotools=mlev=0.015625'
  
module.exports = KaraokeFilter
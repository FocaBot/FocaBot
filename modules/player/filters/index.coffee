FilterPreset = require '../models/audioFilterPreset'
reload = require('require-reload')(require)

class AudioFilters
  constructor:->
    @filters =
      speed: reload './speed'       # | speed=1.5
      reverse: reload './reverse'   # | reverse
      volume: reload './volume'     # | volume=2       (bot commanders)
      lowpass: reload './lowpass'   # | lowpass=500
      highpass: reload './highpass' # | highpass=1000
      bass: reload './bass'         # | bass=20        (bot commanders)
      chorus: reload './chorus'     # | chorus
      echo: reload './echo'         # | echo
      flanger: reload './flanger'   # | flanger=0.5
      phaser: reload './phaser'     # | phaser
      tempo: reload './tempo'       # | tempo=2
      time: reload './time'         # | time=1:23-45   (Start - Duration)
      nofx: reload './nofx'         # | nofx
      karaoke: reload './karaoke'   # | karaoke
      distort: reload './distort'   # | distort=5
      tremolo: reload './tremolo'   # | tremolo=5
      
    @presets =
      # Speed filter
      nightcore: new FilterPreset @filters.speed, 1.5  # | nightcore
      chipmunk: new FilterPreset @filters.speed, 2.0  # | chipmunk
      vaporwave: new FilterPreset @filters.speed, 0.75 # | vaporwave
      # Volume filter
      earrape: new FilterPreset @filters.volume, 25    # | earrape (bot commanders)
    @availableFilters = Object.keys @filters
    @availablePresets = Object.keys @presets

  getFilter: (name,param)=>
    if name in @availableFilters
      return new @filters[name](param, name)
    else if name in @availablePresets
      return @presets[name]
    else return false

module.exports = new AudioFilters()

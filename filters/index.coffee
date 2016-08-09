FilterPreset = require '../models/audioFilterPreset'

class AudioFilters
  constructor:->
    # Filters
    @filters = {
        speed: require './speed'
        reverse: require './reverse'
        volume: require './volume'
        lowpass: require './lowpass'
        highpass: require './highpass'
        bass: require './bass'
    }
    # Presets
    @presets = {
        # Speed filter
        nightcore: new FilterPreset @filters.speed, 1.5
        vaporwave: new FilterPreset @filters.speed, 0.75
        # Volume filter
        earrape: new FilterPreset @filters.volume, 25
    }
    @availableFilters = Object.keys @filters
    @availablePresets = Object.keys @presets

  getFilter: (name,param)=>
    if name in @availableFilters
      return new @filters[name](param, name)
    else if name in @availablePresets
      return @presets[name]
    else return false

module.exports = new AudioFilters()

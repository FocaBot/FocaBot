FilterPreset = require '../models/audioFilterPreset'

class AudioFilters
  constructor:->
    # Filters
    @filters = {
        speed: require './speed'
    }
    # Presets
    @presets = {
        # Speed filter
        nightcore: new FilterPreset @filters.speed, 1.5
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

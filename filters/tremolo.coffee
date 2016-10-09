AudioFilter = require '../models/audioFilter'

class TremoloFilter extends AudioFilter
  validate:=>
    ratio = parseFloat @param or 0.5
    return 'Requested ratio is not a number.' if not ratio
    return 'Ratio must not be higher than 20000' if ratio > 10
    return 'Ratio must not be lower than 0.1' if ratio < 0.1

  toFFMPEGFilter:=> @escape "tremolo=d=0.8:f=#{parseFloat(@param) or 5}"
  toString:=> "[Tremolo #{@param or 5}]"
  
module.exports = TremoloFilter
class AudioFilter
  constructor: (@param, @name)-> true
  validate:-> false
  toFFMPEGFilter:=> "#{@name}=#{@param}"
  toString:=> "[#{@name} #{@param}]"

module.exports = AudioFilter

class AudioFilter
  constructor: (@param, @name)-> true
  validate:-> false
  toFFMPEGFilter:=> "#{@name}=#{@param}"
  toString:=> "[#{@name} #{@param}]"
  escape: (cmd)-> cmd.replace(/(["'$`\\])/g,'\\$1').replace(/\n/g, '\\n')

module.exports = AudioFilter

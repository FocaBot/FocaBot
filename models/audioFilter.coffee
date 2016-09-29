class AudioFilter
  constructor: (@param, @name)-> true
  validate:-> false
  toString:=> "[#{@name} #{@param}]"
  escape: (cmd)-> cmd.replace(/(["'$`\\])/g,'\\$1').replace(/\n/g, '\\n')
  isAdminOnly: => false

module.exports = AudioFilter

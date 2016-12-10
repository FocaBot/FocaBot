class AudioFilter
  constructor: (@param, member, playing, filters)->
    @FFMPEGFilter = "anull"
    @display = "[Unknown]"
    @name = ''
    @avoidRuntime = false
  
  escape: (cmd)-> cmd.replace(/(["'$`\\])/g,'\\$1').replace(/\n/g, '\\n')

module.exports = AudioFilter

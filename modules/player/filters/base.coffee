class AudioFilter
  constructor: (@param, member, playing, filters)-> true
  escape: (cmd)-> cmd.replace(/(["'$`\\])/g,'\\$1').replace(/\n/g, '\\n')
  FFMPEGFilter: "anull"
  display: "[Unknown]"
  name: ''
  avoidRuntime: false

module.exports = AudioFilter

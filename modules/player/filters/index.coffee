preset = require './preset'
filter = (name)-> require "./#{name}"

module.exports =
  bass: filter 'bass'               # | bass=20                    [DJ]
  chorus: filter 'chorus'           # | chorus
  distort: filter 'distort'         # | distort=5
  echo: filter 'echo'               # | echo
  flanger: filter 'flanger'         # | flanger=0.5
  highpass: filter 'highpass'       # | highpass=10000
  karaoke: filter 'karaoke'         # | karaoke
  loop: filter 'loop'               # | loop={start}-{end}-{count} [DJ] [S]
  lowpass: filter 'lowpass'         # | lowpass=500
  nofx: filter 'nofx'               # | nofx                            [S]
  phaser: filter 'phaser'           # | phaser
  reverse: filter 'reverse'         # | reverse                         [S]
  speed: filter 'speed'             # | speed=1
  tempo: filter 'tempo'             # | tempo=1
  treble: filter 'treble'           # | treble=-10                 [DJ]
  tremolo: filter 'tremolo'         # | tremolo=5
  volume: filter 'volume'           # | volume=0                   [DJ]
  bitc: filter 'bitc'               # | bitc=10                    [DJ]
  nightcore: preset 'speed', '1.22' # | nightcore
  chipmunk: preset 'speed', '2.0'   # | chipmunk
  vaporwave: preset 'speed','0.75'  # | vaporwave
  earrape: preset 'volume', '25'    # | earrape                    [DJ]

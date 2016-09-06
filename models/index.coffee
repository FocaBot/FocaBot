thinky = require('thinky') {
  host: process.env.DB_HOST
  port: process.env.DB_PORT
  authKey: process.env.DB_AUTH
  db: process.env.DB_NAME
}
type = thinky.type;
r = thinky.r;
playerCache = {}
AudioPlayer = require '../core/audioPlayer'
QueueManager = require '../core/audioQueue'

Guild = thinky.createModel 'Guild', {
  id: type.string()
  queue: type.array()
}

Guild.define 'getAudioPlayer', (guild)=>
  return playerCache[guild.id] if playerCache[guild.id]?
  playerCache[guild.id] = new AudioPlayer Core, guild

Guild.defineStatic 'getData'

module.exports = { Guild, thinky }

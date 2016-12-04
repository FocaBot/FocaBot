Chance = require 'chance'
{ type } = Core.db

chance = new Chance()

GuildQueue = Core.db.createModel 'GuildQueue', {
  id: type.string()
  guildId: type.string()
  timestamp: type.date().default(new Date())
  # frozenBy: type.string()
  updatedBy: type.string().default(process.env.NODE_APP_INSTANCE or '0')
  nowPlaying: {
    uid: type.string().default(-> chance.guid())
    title: type.string()
    duration: type.number()
    requestedBy: type.string()
    voiceChannel: type.string()
    textChannel: type.string()
    filters: [type.object()]
    path: type.string()
    sauce: type.string()
    thumbnail: type.string()
    originalDuration: type.number()
    voteSkip: [type.string()]
    status: type.string().default('playing')
    time: type.number()
  }
  items: [{
    uid: type.string().default(-> chance.guid())
    title: type.string()
    duration: type.number()
    requestedBy: type.string()
    voiceChannel: type.string()
    textChannel: type.string()
    filters: [type.object()]
    path: type.string()
    sauce: type.string()
    thumbnail: type.string()
    originalDuration: type.number()
    status: type.string().default('queue')
  }]
}

module.exports = GuildQueue

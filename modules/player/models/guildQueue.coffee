{ type } = Core.db

GuildQueue = Core.db.createModel 'GuildQueue', {
  id: type.string()
  guildId: type.string()
  timestamp: type.date().default(new Date())
  # frozenBy: type.string()
  updatedBy: type.string().default(process.env.NODE_APP_INSTANCE or '0')
  nowPlaying: {
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

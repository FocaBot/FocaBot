const reload = require('require-reload')(require)
const EventEmitter = require('events')
const GuildQueue = reload('./guildQueue')

/**
 * Guild Music Player
 */
class GuildPlayer extends EventEmitter {
  /**
   * Creates a new instance
   * @param {Discordie.IGuild} guild - The associated guild
   * @param {object} qData - The queue data
   */
  constructor (guild, qData) {
    super()
    /**
     * The associated guild
     * @type {Discordie.IGuild}
     */
    this.guild = guild
    /**
     * The AudioPlayer for this guild
     * @type {FocaBotCore.AudioPlayer}
     */
    this.audioPlayer = Core.AudioPlayer.getForGuild(guild)
    /**
     * The queue
     * @type {GuildQueue}
     */
    this.queue = new GuildQueue(qData, this)
  }

  /**
   * Starts playback
   */
  async play () {
    if (!this.queue.nowPlaying) return
    if (this.queue.nowPlaying.status === 'playing' && this.audioPlayer.encoderStream) return
    const item = this.queue.nowPlaying
    const stream = await this.audioPlayer.play(item.voiceChannel, item.path, item.flags, item.time)
    // Set bot as self deafen
    item.voiceChannel.join(false, true)
    item.status = 'playing'
    this.emit('playing', item)
    if (item.time === 0) this.emit('start', item)
    // Keep track of the time
    if (item.duration > 0) {
      this.audioPlayer.encoderStream.on('timestamp', () => {
        this.queue.nowPlaying.time = this.audioPlayer.timestamp
      })
    }
    // Handle stream end
    stream.on('end', () => {
      if (item.status === 'paused' || item.status === 'suspended') return
      if (!this.queue._d.items.length) return this.stop()
      this.queue._d.nowPlaying = this.queue._d.shift()
      this.play()
    })
  }

  /**
   * Pauses playback
   */
  pause () {
    const item = this.queue.nowPlaying
    // Can we pause?
    if (!item || item.stat) return
    if (item.status === 'paused' || item.status === 'suspended' || item.status === 'queue') return
    if (!isFinite(item.duration) || item.duration <= 0) throw new Error("Can't pause streams.")
    this.queue.nowPlaying.status = 'paused'
    this.audioPlayer.stop()
    this.emit('paused', item)
  }

  /**
   * Suspends playback (pretty much the same as pause() but without the stream and filter checks)
   */
  suspend () {
    const item = this.queue.nowPlaying
    if (!item || item.stat) return
    if (item.status === 'paused' || item.status === 'suspended' || item.status === 'queue') return
    this.queue.nowPlaying.status = 'suspended'
    this.audioPlayer.stop()
    this.emit('suspended', item)
  }

  /**
   * Hacky seek is still hacky
   * @param {number} time - Position to seek
   */
  seek (time = 0) {
    const item = this.queue.nowPlaying
    if (!item) return
    if (item.stat) throw new Error("Can't seek (static filters)")
    if (item.duration <= 0) throw new Error("Can't seek (livestream)")
    if (time > item.duration || time < 0) throw new Error('Invalid position.')
    const shouldResume = (item.status === 'playing')
    this.pause()
    item.time = time
    if (shouldResume) this.play()
  }

  /**
   * Changes the filters of the current item
   * @param {AudioFilter[]} newFilters - New filters
   */
  updateFilters (newFilters) {
    const item = this.queue.nowPlaying
    if (!item) return
    if (item.stat) throw new Error('The current song has one or more static filters.')
    if (item.duration <= 0) throw new Error("Can't change filters (livestream)")
    if (newFilters.filter(filter => filter.avoidRuntime).length) {
      throw new Error("There's one or more static filters in the new filters.")
    }
    const shouldResume = (item.status === 'playing')
    this.pause()
    item.filters = newFilters
    if (shouldResume) this.resume()
  }
}

module.exports = GuildPlayer

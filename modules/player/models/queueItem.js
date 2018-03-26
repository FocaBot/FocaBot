const { channels } = Core.bot

/**
 * Represents an item in the queue
 */
class QueueItem {
  /**
   * Instantiates a new queue item
   * @param {object} data
   * @param {GuildQueue} queue
   */
  constructor (data, queue) {
    this._d = data
    this.queue = queue
    /**
     * If set to true, a notification will be sent when this element starts playing.
     * It's set to false after such notification is sent.
     * @type {boolean}
     */
    this.notify = true
    /**
     * If set to true, the stream is considered to have errors and will be skipped by the bot.
     * @type {boolean}
     */
    this.error = false
  }

  /**
   * Unique identifier
   * @type {string}
   */
  get uid () {
    return this._d.uid
  }

  /**
   * Title of the element
   * @type {string}
   */
  get title () {
    return this._d.title
  }

  set title (v) {
    this._d.title = v
  }

  /**
   * Length of the element
   * @type {number}
   */
  get duration () {
    let duration = this._d.duration
    if (!duration) return 0
    // Transform the duration acording to the filters
    this.filters.forEach(filter => {
      if (filter.timeModifier) duration = Core.util.evalExpr(filter.timeModifier, duration)
    })
    return duration
  }

  set duration (v) {
    this._d.duration = parseInt(v)
  }

  /**
   * User that requested the element
   * @type {Discordie.IGuildMember}
   */
  get requestedBy () {
    return this.queue.guild.members.find('id', this._d.requestedBy)
  }

  set requestedBy (v) {
    this._d.requestedBy = v.id || v
  }

  /**
   * Voice Channel where the element will be played
   * @type {Discordie.IVoiceChannel}
   */
  get voiceChannel () {
    return channels.find('id', this._d.voiceChannel)
  }

  set voiceChannel (v) {
    this._d.voiceChannel = v.id || v
  }

  /**
   * Text Channel where the element was requested
   * @type {Discordie.ITextChannel}
   */
  get textChannel () {
    return channels.find('id', this._d.textChannel)
  }

  set textChannel (v) {
    this._d.textChannel = v.id || v
  }

  /**
   * Volume
   * @type {number}
   */
  get volume () {
    return this.queue.player.volume
  }

  /**
   * Filters
   * @type {AudioFilter[]}
   */
  get filters () {
    const filters = (this._d.filters || [])
    // Append volume filter
    if (this.queue.player.volume !== 1) {
      return filters.concat({
        FFMPEGFilter: `volume=${this.queue.player.volume}`,
        display: ''
      })
    }
    return filters
  }

  set filters (v) {
    let time = this.originalTime
    // Scale the time according to the filters.
    v.forEach(filter => {
      if (filter.timeModifier) time = Core.util.evalExpr(filter.timeModifier, time)
    })
    this._d.time = time
    this._d.filters = v
  }

  /**
   * URL/Path of the file or stream to play (audio only)
   * @type {string}
   */
  get path () {
    return this._d.path
  }

  set path (v) {
    this._d.path = v
  }

  /**
   * URL/Path of the video stream if present
   * @type {string}
   */
  get videoPath () {
    return this._d.videoPath
  }

  set videoPath (v) {
    this._d.videoPath = v
  }

  /**
   * URL of the element's source page
   * @type {string}
   */
  get sauce () {
    return this._d.sauce
  }

  set sauce (v) {
    this._d.sauce = v
  }

  /**
   * URL of the element's thumbnail picture
   * @type {string}
   */
  get thumbnail () {
    return this._d.thumbnail
  }

  set thumbnail (v) {
    this._d.thumbnail = v
  }

  /**
   * Duration of the element, without filters
   * @type {number}
   */
  get originalDuration () {
    if (!this._d.duration) return 0
    return this._d.duration
  }

  /**
   * Users who voted to skip this element
   * @type {string[]}
   */
  get voteSkip () {
    return this._d.voteSkip
  }

  /**
   * Boolean indicating if the element is a radio stream
   * @type {boolean}
   */
  get radioStream () {
    return this._d.radioStream
  }

  set radioStream (v) {
    this._d.radioStream = v
  }

  /**
   * Playback status.
   *
   * Can be either 'playing', 'paused', 'queue', or 'suspended'
   * @type {string}
   */
  get status () {
    return this._d.status
  }

  set status (v) {
    this._d.status = v
  }

  /**
   * Playback position (timestamp)
   * @type {number}
   */
  get time () {
    if (!this._d.time) return 0
    return this._d.time
  }

  set time (v) {
    this._d.time = parseInt(v)
  }

  /**
   * Playback position (without filters)
   * @type {number}
   */
  get originalTime () {
    let time = this._d.time
    if (!time) return 0
    // Transform the time acording to the filters
    this.filters.forEach(filter => {
      if (filter.inverseTime) time = Core.util.evalExpr(filter.inverseTime, time)
    })
    return time
  }

  /**
   * FFMPEG Flags (from filters and playback position)
   * @type {object}
   */
  get flags () {
    const flags = { input: [], output: [] }
    const filters = []
    // Apply the flags of each filter
    this.filters.forEach(filter => {
      if (filter.FFMPEGInputArgs) flags.input = flags.input.concat(filter.FFMPEGInputArgs)
      if (filter.FFMPEGArgs) flags.output = flags.output.concat(filter.FFMPEGArgs)
      if (filter.FFMPEGFilter) filters.push(filter.FFMPEGFilter)
    })
    // Append the filters
    if (filters.length) flags.output.push('-af', filters.join(', '))
    // Current Time
    if (this.originalTime > 0) flags.input.push('-ss', this.originalTime)
    return flags
  }

  /**
   * True if the item contains static filters
   * @type {boolean}
   */
  get stat () {
                        // heh
    return this.filters.filter(filter => filter.avoidRuntime).length
  }
}

module.exports = QueueItem

const { Users, Channels } = Core.bot

/**
 * Represents an item in the queue
 */
class QueueItem {
  /**
   * Instantiates a new queue item
   * @param {object} data
   */
  constructor (data) {
    this._d = data
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
    return Users.get(this._d.requestedBy).memberOf(this.voiceChannel.guild)
  }

  set requestedBy (v) {
    this._d.requestedBy = v.id || v
  }

  /**
   * Voice Channel where the element will be played
   * @type {Discordie.IVoiceChannel}
   */
  get voiceChannel () {
    return Channels.get(this._d.voiceChannel)
  }

  set voiceChannel (v) {
    this._d.voiceChannel = v.id || v
  }

  /**
   * Text Channel where the element was requested
   * @type {Discordie.ITextChannel}
   */
  get textChannel () {
    return Channels.get(this._d.textChannel)
  }

  set textChannel (v) {
    this._d.textChannel = v.id || v
  }

  /**
   * Filters
   * @type {AudioFilter[]}
   */
  get filters () {
    return this._d.filters || []
  }

  set filters (v) {
    this._d.filters = v
  }

  /**
   * URL/Path of the file or stream to play
   * @type {string}
   */
  get path () {
    return this._d.path
  }

  set path (v) {
    this._d.path = v
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
    // Transform the duration acording to the filters
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
    if (this.originalTime > 0) flags.input.push('-ss', this.time)
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

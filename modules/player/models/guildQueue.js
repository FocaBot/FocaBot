const reload = require('require-reload')(require)
const EventEmitter = require('events')
const Chance = require('chance')
const QueueItem = reload('./queueItem')

/**
 * Represents the queue of a guild
 */
class GuildQueue extends EventEmitter {
  /**
   * Initializes a guild queue
   * @param {object} data - The queue data
   * @param {GuildPlayer} - The associated player
   */
  constructor (data, player) {
    super()
    /**
     * The associated player
     * @type {GuildPlayer}
     */
    this.player = player
    this._d = data
    this.setMaxListeners(30)
  }

  /**
   * Currently playing item
   * @type {QueueItem}
   */
  get nowPlaying () {
    return this._d.nowPlaying ? new QueueItem(this._d.nowPlaying, this) : undefined
  }

  /**
   * Items in the queue
   * @type {QueueItem[]}
   */
  get items () {
    return Object.freeze(this._d.items ? this._d.items.map(item => new QueueItem(item, this)) : [])
  }

  /**
   * Is the queue currently frozen?
   * @type {boolean}
   */
  get frozen () {
    return this._d.frozen
  }

  set frozen (v) {
    this._d.frozen = v
    this.emit('updated')
  }

  /**
   * The associated guild
   * @type {Discordie.IGuild}
   */
  get guild () {
    return this.player.guild
  }

  /**
   * Add an item to the queue
   * @param {object} item - Item to add
   * @param {boolean} silent - If true, no event will be emitted
   * @param {boolean} noPlayback - If true, playback will not be triggered
   * @returns {object}
   */
  addItem (item, silent = false, noPlayback = false) {
    if (!item.path || !item.voiceChannel || !item.requestedBy) return false
    if (item.duration <= 0) item.filters = []
    const itm = { }
    // Convert the item to a JSON-safe object
    Object.assign(itm, item, {
      uid: (new Chance()).guid(),
      voteSkip: [],
      status: 'queue',
      requestedBy: item.requestedBy.id || item.requestedBy,
      voiceChannel: item.voiceChannel.id || item.voiceChannel
    })
    if (item.textChannel && item.textChannel.id) itm.textChannel = item.textChannel.id
    // Add the item
    const index = this._d.items.push(itm) - 1
    const i = this.items[index]
    // Emit events
    if (!silent) this.emit('newItem', { index, item: i })
    if (!silent) this.emit('updated')
    // Nothing being played right now? Start playback inmediately
    if ((!this.nowPlaying || (!this.player.audioPlayer.currentStream && this.nowPlaying.status !== 'paused')) && !noPlayback) {
      this._d.nowPlaying = this._d.items.shift()
      this.player.play()
    }
    return { index, i }
  }

  /**
   * Remove item at index
   * @param {number} index
   * @param {Discordie.IGuildMember} user - User that requested the item removal
   * @returns {object}
   */
  remove (index, user) {
    if (!isFinite(index) || index >= this._d.items.length) return false
    const item = new QueueItem(this._d.items.splice(index, 1)[0])
    this.emit('removed', { item, user })
    this.emit('updated')
    return { item, user }
  }

  /**
   * Remove last item
   * @param {Discordie.IGuildMember} user - User that requested the item removal
   * @returns {object}
   */
  removeLast (user) {
    return this.remove(this.items.length - 1, user)
  }

  /**
   * Swaps 2 items
   * @param {number} index1
   * @param {number} index2
   * @param {Discordie.IGuildMember} user - User that requested the swap
   * @returns {object}
   */
  swap (index1, index2, user) {
    if (!this._d.items[index1] || !this._d.items[index2]) return false
    const _item1 = this._d.items[index1]
    this._d.items[index1] = this._d.items[index2]
    this._d.items[index2] = _item1
    const items = [ this.items[index1], this.items[index2] ]
    this.emit('swapped', { index1, index2, items, user })
    this.emit('updated')
    return { index1, index2, items, user }
  }

  /**
   * Moves an item to another position
   * @param {number} index - Index of the item
   * @param {number} position - New position
   * @param {Discordie.IGuildMember} user
   * @returns {object}
   */
  move (index, position, user) {
    if (index >= this._d.items.length || position >= this._d.items.length) return false
    if (index < 0 || position < 0) return false
    this._d.items.splice(position, 0, this._d.items.splice(index, 1)[0])
    const item = this.items[position]
    this.emit('moved', { index, position, item, user })
    this.emit('updated')
    return { index, position, item, user }
  }

  /**
   * Moves an item to the first position
   * @param {number} index - Index of the item
   * @param {Discordie.IGuildMember} user
   * @returns {object}
   */
  bump (index, user) {
    return this.move(index, 0)
  }

  /**
   * Shuffles the items in the queue
   */
  shuffle () {
    this._d.items = new Chance().shuffle(this._d.items)
    this.emit('shuffled')
    this.emit('updated')
  }

  /**
   * Clears the queue
   */
  clear () {
    this._d.items = []
    this.emit('cleared')
    this.emit('updated')
  }
}

module.exports = GuildQueue

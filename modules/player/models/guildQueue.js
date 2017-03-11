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
  }

  /**
   * Currently playing item
   * @type {QueueItem}
   */
  get nowPlaying () {
    return this._d.nowPlaying ? new QueueItem(this._d.nowPlaying) : undefined
  }

  /**
   * Items in the queue
   * @type {QueueItem[]}
   */
  get items () {
    return Object.freeze(this._d.items ? this._d.items.map(item => new QueueItem(item)) : [])
  }

  /**
   * Is the queue currently frozen?
   * @type {boolean}
   */
  get frozen () {
    return this._d.frozen
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
   * @returns {object}
   */
  addItem (item, silent = false) {
    if (!item.path || !item.voiceChannel || !item.requestedBy) return false
    if (item.duration <= 0) item.filters = []
    const itm = { }
    // Convert the item to a JSON-safe object
    Object.assign(itm, item, {
      voteSkip: [],
      status: 'queue',
      requestedBy: item.requestedBy.id || item.requestedBy,
      voiceChannel: item.voiceChannel.id || item.voiceChannel
    })
    if (item.textChannel && item.textChannel.id) itm.textChannel = item.textChannel.id
    // Add the item
    const index = this._d.items.push(itm)
    const i = this.items[index]
    // Emit events
    if (!silent) this.emit('newItem', { index, item: i })
    if (!silent) this.emit('updated')
    // Nothing being played right now? Start playback inmediately
    if (!this.nowPlaying || !this.player.audioPlayer.encoderStream) {
      this._d.nowPlaying = this._d.items.shift()
      this.player.play()
    }
    return { index, i }
  }

  /**
   * Remove item at index
   * @param {number} index
   * @returns {object}
   */
  remove (index) {
    if (!isFinite(index) || index >= this._d.items.length) return false
    const item = new QueueItem(this._d.items.splice(index, 1)[0])
    this.emit('removed', item)
    this.emit('updated')
    return { item }
  }

  /**
   * Remove last item
   * @returns {object}
   */
  removeLast () {
    return this.remove(this.items.length - 1)
  }

  /**
   * Swaps 2 items
   * @param {number} index1
   * @param {number} index2
   * @returns {object}
   */
  swap (index1, index2) {
    if (!this._d.items[index1] || !this._d.items[index2]) return
    const _item1 = this._d.items[index1]
    this._d.items[index1] = this._d.items[index2]
    this._d.items[index2] = _item1
    const items = [ this.items[index2], this.items[index2] ]
    this.emit('swapped', { index1, index2, items })
    this.emit('updated')
    return { index1, index2, items }
  }

  /**
   * Moves an item to another position
   * @param {number} index - Index of the item
   * @param {number} position - New position
   * @returns {object}
   */
  move (index, position) {
    if (index >= this._d.items.length || position >= this._d.items.length) return
    if (index < 0 || position < 0) return
    this._d.items.splice(position, 0, this._d.items.splice(index, 1)[0])
    const item = this.items[position]
    this.emit('moved', { index, position, item })
    this.emit('updated')
    return { index, position, item }
  }

  /**
   * Moves an item to the first position
   * @param {number} index - Index of the item
   * @returns {object}
   */
  bump (index) {
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

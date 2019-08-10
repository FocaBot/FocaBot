import Chance from 'chance'
import { List } from 'immutable'
import { EventEmitter } from 'events'
import {
  LoopMode,
  PlaybackStatus,
  PlayerBackend,
  QueueEvents,
  RawQueue,
  RuntimeQueueItem,
  UpdateType
} from '../interfaces'
import { Guild, GuildMember, TextChannel, VoiceChannel } from 'discord.js'
import PlayerError, { PlayerErrorCode } from './PlayerError'
import { GuildData } from 'azarasi/lib/guilds'

export default class PlayerQueue extends EventEmitter implements QueueEvents {
  /** Queue items */
  private _items = List<RuntimeQueueItem>([])
  /** Previous Queue items (before last update) */
  private _prev ?: List<RuntimeQueueItem>
  /** If set to true, no modifications can be done to the queue */
  private _frozen = false
  /** Loop mode */
  private _loopMode = LoopMode.None
  /** Internal player */
  player ?: PlayerBackend

  /**
   * Initializes a new queue instance.
   * @param guild - Associated Guild
   */
  constructor (public guild : Guild) {
    super()
  }

  /** Queue items */
  get items () {
    return this._items
  }

  set items(val : List<RuntimeQueueItem>) {
    this._prev = this._items
    this._items = val
  }

  /** If set to true, no modifications can be done to the queue */
  get frozen () {
    return this._frozen
  }

  set frozen (v : boolean) {
    this._frozen = v
    this._prev = this.items
    this.triggerUpdate()
  }

  /** Loop mode */
  get loopMode () {
    return this._loopMode
  }

  set loopMode(v : LoopMode) {
    this._loopMode = v
    this._prev = this.items
    this.triggerUpdate()
  }

  /** Currently playing item */
  get nowPlaying () {
    return this.getItem(0)
  }

  /** Get a specific item */
  getItem (index : number) {
    return this.items.get(index)
  }

  /**
   * Add an item to the queue.
   * @param item - Item to Add
   * @param skipFreeze - Ignore frozen status
   */
  addItem (item : Partial<RuntimeQueueItem>, skipFreeze = false) {
    if (this.frozen && !skipFreeze) throw new PlayerError(PlayerErrorCode.QueueFrozen)
    // Perform basic validation
    if (!item.path || !item.voiceChannel || !item.requestedBy) {
      throw new PlayerError(PlayerErrorCode.InvalidItem)
    }
    // Disable filters for live streams
    if (!item.duration || item.duration < 0) {
      item.filters = {}
    }

    // Add item
    const index = this.items.count()
    this.items = this.items.push({
      ...item,
      uid: new Chance().guid(),
      lastUpdate: Date.now(),
      status: PlaybackStatus.Queue,
      voteSkip: [],
      filters: item.filters || {},
      // For some reason TypeScript is forcing me to specify those fields, even though i do validation above.
      path: item.path!,
      requestedBy: item.requestedBy!,
      voiceChannel: item.voiceChannel!
    })
    const newItem = this.getItem(index)

    // Trigger events
    this.emit('add', index, newItem)
    this.triggerUpdate()

    return { index, item: newItem }
  }

  /**
   * Remove an item from the queue.
   * @param index - Index of the item to remove
   * @param by - User that initiated the action
   * @param skipFreeze - Ignore frozen status
   */
  remove (index : number, by : GuildMember, skipFreeze = false) {
    if (this.frozen && !skipFreeze) throw new PlayerError(PlayerErrorCode.QueueFrozen)
    if (!this.items.has(index)) throw new PlayerError(PlayerErrorCode.InvalidItem)
    const item = this.items.get(index)
    this.items = this.items.remove(index)
    this.triggerUpdate()
    this.emit('remove', item, by)
    return { item, by }
  }

  /**
   * Remove multiple items from the queue.
   * @param startIndex - First item index to delete
   * @param endIndex - Last item index to delete
   * @param by - User that initiated the action
   * @param skipFreeze - Ignore frozen status
   */
  removeRange (startIndex : number, endIndex : number, by : GuildMember, skipFreeze = false) {
    if (this.frozen && !skipFreeze) throw new PlayerError(PlayerErrorCode.QueueFrozen)
    if (!this.items.has(startIndex) || !this.items.has(endIndex)) throw new PlayerError(PlayerErrorCode.InvalidItem)
    const items = this.items.slice(startIndex, endIndex)
    this.items = this.items.splice(startIndex, endIndex - startIndex + 1)
    this.triggerUpdate()
    this.emit('removeRange', items, by)
    return { items, by }
  }

  /**
   * Swap the positions of two items.
   * @param indexA - First item
   * @param indexB - Second item
   * @param by - User that initiated the action
   * @param skipFreeze - Ignore frozen status
   */
  swap (indexA : number, indexB : number, by : GuildMember, skipFreeze = false) {
    if (this.frozen && !skipFreeze) throw new PlayerError(PlayerErrorCode.QueueFrozen)
    if (!this.items.has(indexA) || !this.items.has(indexB)) throw new PlayerError(PlayerErrorCode.InvalidItem)
    const itemA = this.items.get(indexA)!
    const itemB = this.items.get(indexB)!
    this.items = this.items.set(indexA, itemB).set(indexB, itemA)
    this.emit('swap', { index: indexA, item: itemA }, { index: indexB, item: itemB }, by)
    this.triggerUpdate()
    return { indexA, itemA, indexB, itemB, by }
  }

  /**
   * Move an item to a new position.
   * @param index - Item index
   * @param targetIndex - New index
   * @param by - User that initiated the action
   * @param skipFreeze - Ignore frozen status
   */
  move (index : number, targetIndex : number, by : GuildMember, skipFreeze = false) {
    if (this.frozen && !skipFreeze) throw new PlayerError(PlayerErrorCode.QueueFrozen)
    if (!this.items.has(index) || targetIndex >= this.items.count()) throw new PlayerError(PlayerErrorCode.InvalidItem)
    if (targetIndex < 0) throw new PlayerError(PlayerErrorCode.InvalidItem)
    const item = this.items.get(index)!
    this.items = this.items.remove(index).splice(targetIndex, 0, item)
    this.triggerUpdate()
    this.emit('move', { index, item }, by)
    return { index, item, by }
  }

  /**
   * Shuffles the order of the items except the first one (since it's the one that's playing).
   * @param skipFreeze - Ignore frozen status
   */
  shuffle (skipFreeze = false) {
    if (this.frozen && !skipFreeze) throw new PlayerError(PlayerErrorCode.QueueFrozen)
    this.items = List(new Chance().shuffle(this.items.toArray()))
    this.triggerUpdate()
    this.emit('shuffle')
  }

  /**
   * Remove all items from the queue.
   * @param skipFreeze - Ignore frozen status
   */
  clear (skipFreeze = false) {
    if (this.frozen && !skipFreeze) throw new PlayerError(PlayerErrorCode.QueueFrozen)
    this.items = this.items.clear()
    this.triggerUpdate()
    this.emit('clear')
  }

  /**
   * Apply changes to a queue item
   * @param index - Item index
   * @param changes - Changes to apply
   * @param type - Update Type
   */
  update (index : number, changes : Partial<RuntimeQueueItem>, type = UpdateType.Normal) {
    if (!this.items.has(index)) throw new PlayerError(PlayerErrorCode.InvalidItem)
    const item = this.items.get(index)!
    this.items = this.items.set(index, { ...item, ...changes, lastUpdate: Date.now() })
    if (type === UpdateType.Normal) this.triggerUpdate()
    if (type !== UpdateType.Internal) this.emit('itemUpdate', index, item)
  }

  /**
   * Trigger update event and synchronize the player backend.
   */
  triggerUpdate () {
    this.emit('update')
    if (!this.player || ! this._prev) return
    // Get active stream from previous and current states to check for changes
    const prev = this._prev.get(0)
    const now = this.nowPlaying
    // The active stream has changed
    if (!prev || !now || prev.uid !== now.uid || prev.lastUpdate !== now.lastUpdate) {
      // Stop previous stream
      if (prev) this.player.pause()
      // Start new stream
      if (now) this.player.start()
    }
  }

  /** Get instance from data */
  static async Deserialize (guild : Guild, data : RawQueue) : Promise<PlayerQueue> {
    const queue = new PlayerQueue(guild)
    queue.items = List((await Promise.all(data.items.map(async item => {
      try {
        return {
          ...item,
          requestedBy: await guild.fetchMember(item.requestedBy),
          voiceChannel: guild.channels.find(c => c.type === 'voice' && c.id === item.voiceChannel) as VoiceChannel,
          textChannel: guild.channels.find(c => c.type === 'text' && c.id === item.textChannel) as TextChannel,
        }
      } catch (e) {
        return undefined
      }
    }))).filter(i => i) as RuntimeQueueItem[])
    queue._frozen = data.frozen
    queue._loopMode = data.loopMode
    return queue
  }

  /** Get data from instance */
  toJSON () : RawQueue {
    return {
      items: this.items.map(item => ({
        ...item,
        requestedBy: item.requestedBy.id,
        voiceChannel: item.voiceChannel.id,
        textChannel: item.textChannel && item.textChannel.id,
        duration: undefined,
        time: undefined
      })).toArray(),
      frozen: this.frozen,
      loopMode: this.loopMode
    }
  }
}

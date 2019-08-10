import PlayerQueue from '../runtime/PlayerQueue'
import { RuntimeQueueItem } from './QueueItem'
import { EventEmitter } from 'events'

export interface PlayerBackend extends EventEmitter {
  /** Associated Queue */
  queue : PlayerQueue
  /** Stream duration */
  duration ?: number
  /** Stream current time */
  time : number

  /** Start playback of the first queue item */
  start () : void
  /** Pause the currently playing item */
  pause () : void
  /** Suspend playback */
  suspend () : void
  /** Resume playback the currently paused or suspended item */
  resume () : void
  /** Stop playback immediately and optionally disconnect */
  stop (disconnect : boolean) : void
  /** Grab screenshot from the currently playing item */
  grabScreenshot () : Promise<Buffer>
  /** Fetch metadata about an item */
  fetchMetadata (item : RuntimeQueueItem) : Promise<any>
  /**
   * Perform a seek in the current item
   * @param time - Time to seek to in seconds.
   */
  seek (time : number) : void
  /**
   * Apply global volume.
   * @param volume - New volume in the range 0-100.
   */
  setVolume (volume : number) : void

  /** Fires when an item starts playing (or is resumed) */
  on (event: 'itemStart', listener : (item : RuntimeQueueItem) => void) : this
  /** Fires when an item gets paused */
  on (event: 'itemPause', listener : (item : RuntimeQueueItem) => void) : this
  /** Fires when an item finishes playback */
  on (event: 'itemEnd', listener : (item : RuntimeQueueItem) => void) : this
  /** Fires when playback gets suspended */
  on (event: 'suspend', listener : () => void) : this
  /** Fires when playback gets stopped */
  on (event: 'stop', listener : () => void) : this
  /** Fires when there's nothing more to play */
  on (event: 'end', listener : () => void) : this
  /** Fires when an item's playback position gets manually changed */
  on (event: 'seek', listener : (item : RuntimeQueueItem, time : number) => void) : this
  /** Fires when the volume gets updated */
  on (event: 'volumeUpdate', listener : (newVolume : number) => void) : this
}

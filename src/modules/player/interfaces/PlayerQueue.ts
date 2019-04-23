import { RawQueueItem } from './QueueItem'

export interface QueueEvents {

}

export interface RawQueue {
  items : RawQueueItem[]
  frozen : boolean
  loopMode : LoopMode
}

export enum LoopMode {
  /** Loop disabled */
  None = 'none',
  /** Loop single item */
  Single = 'single',
  /** Loop the entire playlist */
  All = 'all'
}

export enum UpdateType {
  /** Normal update, fire events and synchronize the player backend */
  Normal,
  /** Discrete update, fire events but don't synchronize the player backend */
  Discrete,
  /** Internal update, don't fire events or synchronize the player backend */
  Internal
}

import Discord from 'discord.js'

/**
 * Base queue item.
 */
export interface BaseQueueItem {
  /** Unique identifier */
  uid : string
  /** Item title */
  title ?: string
  /** Timestamp of the last update */
  lastUpdate : number
  /** Raw stream duration in seconds */
  duration ?: number
  /** Filter IDs and their parameters */
  filters : {
    [filterId : string] : string
  }
  /** Path or URL of the audio stream */
  path : string
  /** Path or URL of the video stream if present */
  videoPath ?: string
  /** URL of the item's source page */
  source ?: string
  /** URL of the thumbnail picture */
  thumbnail ?: string
  /** Users IDs of those who voted to skip this item */
  voteSkip ?: string[]
  /** True if the item is a web radio stream */
  radioStream ?: boolean
  /** Current playback status */
  status ?: PlaybackStatus
  /** Playback offset */
  offset ?: number
}

/**
 * Raw representation of a queue item. Must be JSON-friendly, used for database and backend serialization.
 */
export interface RawQueueItem extends BaseQueueItem {
  /** User ID of the requester */
  requestedBy : string
  /** Voice channel ID for playback */
  voiceChannel : string
  /** Text channel ID for notifications */
  textChannel ?: string
}

/**
 * Runtime representation of a queue item.
 */
export interface RuntimeQueueItem extends BaseQueueItem {
  /** Member who requested the item */
  requestedBy : Discord.GuildMember
  /** Voice Channel for playback */
  voiceChannel : Discord.VoiceChannel
  /** Text Channel for notifications */
  textChannel ?: Discord.TextChannel
}

/**
 * Item playback status.
 */
export enum PlaybackStatus {
  /** The item is currently playing */
  Playing = 'playing',
  /** The item is currently paused */
  Paused = 'paused',
  /** The item is in queue */
  Queue = 'queue',
  /** The playback was automatically suspended due to inactivity */
  Suspended = 'suspended'
}

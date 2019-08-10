import { EventEmitter } from 'events'
import { Guild } from 'discord.js'
import { Azarasi } from 'azarasi'
import { PlayerBackend, RawQueue } from '../interfaces'
import PlayerQueue from './PlayerQueue'
import FFMPEGBackend from '../backends/ffmpeg'

export default class GuildPlayer extends EventEmitter {
  public queue !: PlayerQueue
  public backend !: PlayerBackend

  constructor (private az : Azarasi, public guild : Guild) {
    super()
  }

  /**
   * Initialization routine
   */
  async init () {
    // Load Queue Data
    const { data } = await this.az.guilds.getGuild(this.guild)
    if (data.queue) {
      this.queue = await PlayerQueue.Deserialize(this.guild, data.queue as RawQueue)
    } else {
      this.queue = new PlayerQueue(this.guild)
    }
    // Initialize backend
    switch (this.az.properties.focaBot.player.backend) {
      case 'ffmpeg':
        this.backend = new FFMPEGBackend(this.az, this.queue)
        break
      case 'focastreamer':
        throw new Error('FocaStreamer backend not yet implemented.')
      default:
        throw new Error('Invalid player backend provided in settings. Valid options are "ffmpeg" and "focastreamer".')
    }
    // Link queue to backend
    this.queue.player = this.backend
  }
}

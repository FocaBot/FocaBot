import { EventEmitter } from 'events'
import { Guild } from 'discord.js'
import { Azarasi } from 'azarasi'
import { PlayerBackend } from '../interfaces'

export default class GuildPlayer extends EventEmitter {
  constructor (private az : Azarasi, public guild : Guild, public backend : PlayerBackend) {
    super()
  }

  async connect () {

  }
}

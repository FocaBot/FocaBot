const util = require('../util')

/**
 * Imports a Playlist to the queue.
 */
class PlaylistImport {
  /**
   * Initializes a new import.
   * @param {Discordie.IMessage} msg - Original Message
   * @param {object[]} list - Video list extracted by youtube-dl
   * @param {object[]} filters - Filters
   * @param {GuildPlayer} player - Guild Player
   */
  constructor (msg, list, filters, player) {
    if (!msg || !list || !player) throw new Error('Not enough arguments')
    this.message = msg
    this.textChannel = msg.channel
    this.voiceChannel = msg.member.getVoiceChannel()
    this.requestedBy = msg.member
    this.items = list
    this.filters = filters
    this.done = []
    this.errored = []
    this.player = player
    this.started = false
    this.over = false
    if (!this.voiceChannel) throw new Error('Not joined to a voice channel')
  }

  /**
   * Starts the import
   */
  async import () {
    this.started = true
    this.updateMessage()
    this.interval = setInterval(() => this.sending ? false : this.updateMessage(), 2500)
    // Get information on each video
    for (let i = 0; i < this.items.length; i++) {
      const item = this.items[i].url
      // Not a valid item
      if (!item) {
        this.errored.push(item)
        continue
      }
      try {
        const info = await util.getInfo(item)
        if (info.forEach) { // Nested playlist
          this.items = this.items.concat(info)
        } else {
          if (item.time > info.duration || item.time < 0) throw new Error('Invalid start time.')
          this.done.push(Object.assign(info, { filters: item.filters || this.filters, startAt: item.time || 0 }))
        }
      } catch (e) {
        console.error(e)
        this.errored.push(item)
      }
    }
    this.over = true
    // Add each video to the queue
    for (let i; i < this.done.length; i++) {
      const item = this.done[i]
      try {
        await Core.util.delay(16) //
        util.processInfo(item, this.message, this.player, true, this.voiceChannel)
      } catch (e) {
        console.error(e)
      }
    }
  }

  /**
   * Updates the loading message
   */
  async updateMessage () {
    if (!this.started) return
    if (this.over) clearInterval(this.interval)
    const embed = {
      author: {
        name: this.over ? '✅ Playlist Added!' : 'Loading Playlist...',
        icon_url: this.over ? undefined : 'https://d.thebitlink.com/wheel.gif'
      },
      description: `**[${this.done.length}/${this.items.length}]** playlist items imported.`,
      footer: {
        icon_url: this.requestedBy.staticAvatarURL,
        text: `Requested by ${this.requestedBy.name}`
      }
    }
    if (this.errored.length) embed.description += `\nError importing **${this.errored.length}** items.`
    try {
      this.sending = true
      if (this.pMessage) await this.pMessage.edit('', embed)
      else this.pMessage = await this.textChannel.sendMessage('', false, embed)
      this.sending = false
    } catch (e) {
      console.error(e)
    }
  }
}

module.exports = PlaylistImport

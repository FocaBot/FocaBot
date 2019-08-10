/**
 * Player Module
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 */
import { Azarasi, CommandContext } from 'azarasi'
import { registerCommand } from 'azarasi/lib/decorators'
import { Guild } from 'discord.js'
import GuildPlayer from './runtime/GuildPlayer'

export default class Player extends Azarasi.Module {
  private instanceCache = new Map<Guild, GuildPlayer>()

  /**
   * Get player instance for a specific guild.
   * @param guild - Guild
   */
  async getPlayer(guild : Guild) {
    // Find in cache first
    if (this.instanceCache.has(guild)) return this.instanceCache.get(guild)!
    // Create a new instance if it doesn't exist.
    const instance = new GuildPlayer(this.az, guild)
    await instance.init()
    this.instanceCache.set(guild, instance)
    return instance
  }

  /**
   * Add items to the queue.
   * @param items - Items to add. One per line.
   * Can be YouTube search queries/IDs or any URL supported by youtube-dl.
   * Use @ to specify a start timestamp (play NOMA - Brain Power @1:35)
   * Use | to specify filters (play Delta Heavy - White Flag | speed=1.22 lowpass=1000)
   */
  @registerCommand({ argSeparator: '\n', aliases: ['p'] })
  async play ({ msg, l } : CommandContext, ...items : string[]) {
    const player = await this.getPlayer(msg.guild)

    // Get target voice channel for playback
    const voiceChannel = msg.member.voiceChannel
    if (!voiceChannel) return msg.reply(l.player.noVoice)

    items.forEach(url => player.queue.addItem({
      path: url,
      voiceChannel,
      requestedBy: msg.member
    }))
  }
}

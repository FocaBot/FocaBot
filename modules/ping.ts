/**
 * Ping Module
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 */
import { Azarasi, CommandArgs } from 'azarasi'
import { Message } from 'discord.js'
import { registerCommand } from 'azarasi/lib/decorators'

export default class Ping extends Azarasi.Module {
  /**
   * Obligatory ping command.
   */
  @registerCommand async ping({ msg } : CommandArgs) {
    // Send a message and wait until it's sent
    const ping = await msg.channel.send('🏓 Pong!') as Message
    // Subtract the original message timestamp from the timestamp of the ping message
    const ms = ping.createdTimestamp - msg.createdTimestamp
    // Update reply
    ping.edit(`🏓 Pong! \`${ms}ms\``)
  }
}

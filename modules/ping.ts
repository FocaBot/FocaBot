/**
 * Ping Module
 */
import { Azarasi } from 'azarasi'
import { Message } from 'discord.js'

export default class Ping extends Azarasi.Module {
  init () {
    this.registerCommand('ping', async ({ msg }) => {
      // Send a message and wait until it's sent
      const ping = await msg.channel.send('🏓 Pong!') as Message
      // Subtract the original message timestamp from the timestamp of the ping message
      const ms = ping.createdTimestamp - msg.createdTimestamp
      // Update reply
      ping.edit(`🏓 Pong! \`${ms}ms\``)
    })
  }
}

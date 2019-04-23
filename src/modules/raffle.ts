/**
 * Raffle module.
 * @author TheBITLINK aka BIT
 * @license MIT
 **/
import { Azarasi, CommandContext } from 'azarasi'
import { registerCommand } from 'azarasi/lib/decorators'
import { Guild, GuildMember } from 'discord.js'
import { Settings } from 'azarasi/lib/settings'
import Chance from 'chance'

export default class Raffle extends Azarasi.Module {
  chance = new Chance()

  init () {
    this.registerParameter('raffleMention',{
      type: Boolean,
      def: false
    })
  }

  /**
   * Starts a new raffle.
   * @param pollType - Poll type ("single" or "multi")
   */
  @registerCommand({ adminOnly: true })
  async raffleStart ({ msg, s, l } : CommandContext, pollType : string) {
    msg.delete().catch(() => {})
    // Check if another raffle is currently active.
    const raffle = await this.getRaffleDataForGuild(msg.guild)
    if (raffle) {
      return msg.reply(
        l.gen(l.raffle.previousRaffleOpen, raffle.participants.length.toString(), s.prefix + 'raffleClose')
      )
    }
    // Create the new raffle
    await this.createRaffleDataForGuild(msg.guild, pollType as string || 'single')
    // Announce it
    msg.channel.send(
      (s.raffleMention ? '@everyone ' : '') +
      l.gen(l.raffle.raffleStarted, s.prefix + 'raffleJoin')
    )
  }

  /**
   * Join an active raffle.
   */
  @registerCommand async raffleJoin ({ msg, s, l } : CommandContext) {
    msg.delete().catch(() => {})
    // Check for an active raffle.
    const raffle = await this.getRaffleDataForGuild(msg.guild)
    if (!raffle) return msg.reply(l.raffle.noRaffle)
    // Check if the user already joined.
    if (raffle.participants.indexOf(msg.member.id) >= 0 || raffle.winners.indexOf(msg.member.id) >= 0) {
      return msg.reply(l.raffle.alreadyJoined)
    }
    // Add member to participants array and save
    raffle.participants.push(msg.member.id)
    await this.updateRaffleDataForGuild(msg.guild, raffle)
    // Update user stats
    const uStats = await this.getStatsForMember(msg.member)
    uStats.total.push(msg.guild.id)
    await this.updateStatsForMember(msg.member, uStats)
    // Send confirmation
    msg.channel.send(l.gen(l.raffle.joined, msg.member.toString(), raffle.participants.length.toString()))
  }

  /**
   * Picks a random winner from the participants
   */
  @registerCommand({ adminOnly: true })
  async rafflePick ({ msg, s, l } : CommandContext) {
    msg.delete().catch(() => {})
    // Check for an active raffle.
    const raffle = await this.getRaffleDataForGuild(msg.guild)
    if (!raffle) return msg.reply(l.raffle.noRaffle)
    // Filter out participants that already won if we're not in "multi" mode.
    let participants = raffle.participants
    if (raffle.type !== 'multi') {
      participants = raffle.participants.filter(p => raffle.winners.indexOf(p) < 0)
    }
    if (participants.length <= 0) return msg.reply(l.raffle.noParticipantsLeft)
    // Pick a winner
    const winner = this.chance.pickone(participants)
    raffle.winners.push(winner)
    // Update raffle data
    await this.updateRaffleDataForGuild(msg.guild, raffle)
    // Find member instance
    const winnerMember = msg.guild.members.find(m => m.id === winner)
    if (!winnerMember) return msg.reply(l.generic.error)
    // Update user stats
    const uStats = await this.getStatsForMember(msg.member)
    uStats.won.push(msg.guild.id)
    await this.updateStatsForMember(msg.member, uStats)
    // Announce
    msg.channel.send(l.gen(l.raffle.winner, winnerMember.toString()))
  }

  /**
   * Close the active raffle.
   */
  @registerCommand({ adminOnly: true })
  async raffleClose ({ msg, s, l } : CommandContext) {
    msg.delete().catch(() => {})
    // Check for an active raffle.
    const raffle = await this.getRaffleDataForGuild(msg.guild)
    if (!raffle) return msg.reply(l.raffle.noRaffle)
    // Delete data
    await this.deleteRaffleDataForGuild(msg.guild)
    // Display raffle stats
    msg.channel.send(
`${s.raffleMention ? '@everyone ' : ''}
${l.raffle.closed}

${l.raffle.overview}
${l.gen(l.raffle.totalParticipants, raffle.participants.length.toString())}
${l.gen(l.raffle.totalWinners, raffle.winners.length.toString())}
${raffle.winners.length > 0 ? '\n\n' + l.raffle.placements + '\n' : '' }
${raffle.winners.map(
  (winner, ix) => `**${ix+1}**. ${msg.guild.members.find(m => m.id === winner)}`
).join('\n')}
`
    )
  }

  /**
   * Display raffle stats for a user.
   * @param member - Member to check.
   */
  @registerCommand async raffleStats ({ msg, l } : CommandContext, member ?: GuildMember) {
    const target = member || msg.member
    const uStats = await this.getStatsForMember(target)
    msg.channel.send({ embed: {
      title: l.gen(l.raffle.raffleStats, target.displayName),
      thumbnail: {
        url: target.user.displayAvatarURL
      },
      fields: [
        // Stats for current guild
        {
          name: msg.guild.name,
          value: [
            '\n',
            l.gen(l.raffle.participated, uStats.total.filter(gid => gid === msg.guild.id).length.toString()),
            l.gen(l.raffle.won, uStats.won.filter(gid => gid === msg.guild.id).length.toString())
          ].join('\n'),
          inline: true
        },
        // Global stats
        {
          name: l.raffle.overall,
          value: [
            '\n',
            l.gen(l.raffle.participated, uStats.total.length.toString()),
            l.gen(l.raffle.won, uStats.won.length.toString())
          ].join('\n'),
          inline: true
        }
      ]
    }})
  }

  /**
   * Helper function to get raffle data for a guild.
   * @param guild - Guild to fetch
   */
  async getRaffleDataForGuild (guild : Guild) : Promise<IRaffleData | null> {
    return this.az.data.get(`Raffle:${guild.id}`) as Promise<IRaffleData | null>
  }

  /**
   * Helper function to create blank raffle data for a guild.
   * @param guild - Target guild
   * @param type - Raffle type
   */
  async createRaffleDataForGuild (guild : Guild, type : string) : Promise<IRaffleData> {
    const blankState = {
      type,
      participants: [],
      winners: []
    } as IRaffleData
    await this.updateRaffleDataForGuild(guild, blankState)
    return blankState
  }

  /**
   * Helper function to update raffle data for a guild
   * @param guild - Guild to update
   * @param raffleData - New data
   */
  async updateRaffleDataForGuild (guild : Guild, raffleData : IRaffleData) {
    return this.az.data.set(`Raffle:${guild.id}`, raffleData)
  }

  /**
   * Helper function to delete raffle data for a guild.
   * @param guild - Guild to delete data from
   */
  async deleteRaffleDataForGuild (guild : Guild) {
    return this.az.data.del(`Raffle:${guild.id}`)
  }

  /**
   * Helper function to get (or generate) stats for a guild member.
   * @param member - Member to query
   */
  async getStatsForMember (member : GuildMember) : Promise<IRaffleStats> {
    // Try to fetch existing data
    const data = await this.az.data.get(`RaffleStats:${member.id}`) as IRaffleStats
    return data || { total: [], won: [] }
  }

  /**
   * Helper function to update stats for a guild member.
   * @param member - Member to update
   * @param stats - Stats data
   */
  async updateStatsForMember (member : GuildMember, stats : IRaffleStats) {
    return this.az.data.set(`RaffleStats:${member.id}`, stats)
  }
}

/**
 * Guild raffle data.
 */
interface IRaffleData {
  /**
   * Raffle type.
   * "single" raffles can only be won by the same person once.
   * "multi" raffles can be won multiple times by the same person.
   * Both allow for multiple winners, but "single" (the default) avoids the same person from being picked twice.
   */
  type : 'single' | 'multi',
  /**
   * User IDs of the raffle participants.
   */
  participants : string[],
  /**
   * User IDs of the current winners.
   */
  winners: string[]
}

/**
 * Raffle stats for a user.
 */
interface IRaffleStats {
  /**
   * Guild IDs of the raffles the user has participated in.
   */
  total: string[],
  /**
   * Guild IDs of the raffles the user has won.
   */
  won: string[]
}

declare module 'azarasi/lib/settings' {
  interface Settings {
    raffleMention: boolean
  }
}


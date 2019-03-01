/**
 * Moderation module.
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 **/
import { Azarasi, CommandContext } from 'azarasi'
import { registerCommand, registerEvent } from 'azarasi/lib/decorators'
import Discord, { GuildMember, Message, TextChannel } from 'discord.js'

// TODO: Add more moderation features.
export default class Moderation extends Azarasi.Module {
  init () {
    // Anti-Raid
    this.registerParameter('antiRaid', { type: Boolean, def: false })
    this.registerParameter('antiRaid_thresholdTime', { type: Number, def: 30 })
    this.registerParameter('antiRaid_thresholdUsers', { type: Number, def: 3, integer: true })
    this.registerParameter('antiRaid_alertChannel', { type: TextChannel })
    this.registerParameter('antiRaid_role', { type: String, def: 'none' })
    this.registerParameter('antiRaid_increaseVerification', { type: Boolean, def: false })
    // Auto-Role
    this.registerParameter('autoRole', { type: String, def: 'off' })
  }

  /**
   * Kicks a member.
   * @param member - Member to kick
   * @param reason - Reason to include in the audit log.
   */
  @registerCommand({ requiredPermissions: ['KICK_MEMBERS'], argSeparator: ' ' })
  async kick ({ msg, l } : CommandContext, member : GuildMember, ...reason : string[]) {
    if (!member) return
    try {
      await member.kick(`${msg.member.displayName}: ${reason.join(' ') || l!.moderation.noReason}`)
      return msg.reply(l!.moderation.kicked)
    } catch (e) {
      console.error(e)
      return msg.reply(l!.moderation.cantKick)
    }
  }

  /**
   * Bans a member.
   * @param member - Member to ban
   * @param reason - Reason to include in the audit log
   */
  @registerCommand({ requiredPermissions: ['BAN_MEMBERS'], argSeparator: ' ' })
  async ban ({ msg, l } : CommandContext, member : GuildMember, ...reason : string[]) {
    if (!member) return
    try {
      await member.ban(`${msg.member.displayName}: ${reason.join(' ') || l!.moderation.noReason}`)
      return msg.reply(l!.moderation.banned)
    } catch (e) {
      console.error(e)
      return msg.reply(l!.moderation.cantBan)
    }
  }

  /**
   * Resets all anti-raid features to the initial state.
   * @param msg
   */
  @registerCommand({ adminOnly: true })
  async resetAntiRaid ({ msg, s, l, guildData } : CommandContext) {
    if (!guildData.antiRaidTriggered) {
      return msg.reply(l!.moderation.antiRaidNotActive)
    }
    const raidUsers = guildData.antiRaidUsers || []
    // Reset trigger status
    guildData.antiRaidTriggered = false
    guildData.antiRaidUsers = []
    try {
      await msg.channel.send(l!.moderation.raidResetting)
      // Reset verification level
      if (s.antiRaid_increaseVerification) {
        await msg.guild.setVerificationLevel(guildData.antiRaidPreviousVerificationLevel)
      }
      // Reset assigned roles
      if (s.antiRaid_role) {
        const role = msg.guild.roles.find(r => r.name === s.antiRaid_role)
        if (role) {
          await Promise.all(raidUsers.map(async u => {
            try {
              const m = await msg.guild.fetchMember(u.id)
              await m.removeRole(role, l!.moderation.raidResetting)
            } catch (e) {}
          }))
        }
      }
      // Prompt kick
      const prompt = await msg.channel.send(l!.moderation.raidKickPrompt) as Message
      prompt.react('❌')
      prompt.react('✅')
      const promptResponse = await prompt.awaitReactions(
        (r, user) => (['❌', '✅'].indexOf(r.emoji.name) >= 0) && !user.bot && user.id === msg.author.id,
        { max: 1 }
      )
      await prompt.clearReactions()
      if (promptResponse.first().emoji.name === '✅') {
        // Kick everyone!
        await prompt.edit(l!.moderation.antiRaidNotActive)
        await Promise.all(raidUsers.map(async u => {
          try {
            const m = await msg.guild.fetchMember(u.id)
            if (m.roles.array().length > 1) return
            await m.kick(`${msg.member.displayName}: ${l!.moderation.raidKick}`)
          } catch (e) {}
        }))
      } else {
        // Don't kick anyone
        await prompt.delete()
      }
      await guildData.save()
      await msg.reply(l!.generic.success)
    } catch (e) {
      console.error(e)
      msg.reply(l!.generic.error)
    }
  }

  /**
   * Handles new members.
   * @param member - New member
   */
  @registerEvent('discord.guildMemberAdd')
  async handleNewMember (member : Discord.GuildMember) {
    const { data } = await this.az.guilds.getGuild(member.guild)
    const s = await this.az.settings.getForGuild(member.guild)
    const l = this.az.locales.getLocale(s.locale!)
    // Anti Raid
    if (s.antiRaid) {
      if (!data.antiRaidUsers) data.antiRaidUsers = []
      data.antiRaidUsers.push({ id: member.id, timestamp: Date.now() })
      if (data.antiRaidTriggered) {
        // Anti-Raid is currently triggered, give role
        if (s.antiRaid_role !== 'none') {
          const role = member.guild.roles.find(r => r.name === s.antiRaid_role)
          if (role) await member.addRole(role, l!.moderation.raidDetected)
        }
      } else {
        // Filter users outside of the time threshold.
        data.antiRaidUsers = data.antiRaidUsers.filter(
          u => Date.now() - u.timestamp < s.antiRaid_thresholdTime * 1000
        )
        // Check if the number of users joined in the last {n} seconds are enough to trigger the anti-raid
        if (data.antiRaidUsers.length >= s.antiRaid_thresholdUsers) {
          // MAXIMUM ALERT MODE
          data.antiRaidTriggered = true
          // Send alert
          if (s.antiRaid_alertChannel !== 'none') {
            const channel = member.guild.channels.get(s.antiRaid_alertChannel) as Discord.TextChannel
            if (channel) channel.send(`${l!.moderation.raidDetected} ${l!.gen(l!.moderation.antiRaidAlert, s.prefix || '')}`)
          }
          // Set verification level
          if (s.antiRaid_increaseVerification) {
            data.antiRaidPreviousVerificationLevel = member.guild.verificationLevel
            member.guild.setVerificationLevel(4, l!.moderation.raidDetected)
          }
          // Apply roles
          if (s.antiRaid_role !== 'none') {
            const role = member.guild.roles.find(r => r.name === s.antiRaid_role)
            if (role) {
              data.antiRaidUsers.forEach(async u => {
                const m = await member.guild.fetchMember(u.id)
                await m.addRole(role, l!.moderation.raidDetected)
              })
            }
          }
        }
      }
      await data.save()
    }
    // Auto Role
    if (!data.antiRaidTriggered && s.autoRole !== 'off') {
      const role = member.guild.roles.find(r => r.name === s.autoRole)
      if (role) await member.addRole(role, l!.moderation.autoRole)
    }
  }
}

export interface AntiRaidUserEntry {
  id : string
  timestamp : number
}

declare module 'azarasi/lib/settings' {
  interface Settings {
    /**
     * Anti raid feature (experimental)
     * If {n} users join within {n} seconds of each other,
     * send an alert to the specified channel and optionally do other preventive actions.
     */
    antiRaid : boolean
    /** Amount of time in seconds required between joins to trigger the anti-raid */
    antiRaid_thresholdTime : number
    /** Amount of users required before triggering the anti-raid. */
    antiRaid_thresholdUsers : number
    /** Send an alert to this channel if a potential raid is detected */
    antiRaid_alertChannel : string
    /** Optionally give a role to suspicious users. Set to 'none' to disable */
    antiRaid_role : string
    /** Optionally increase the guild's verification level to the maximum possible value. */
    antiRaid_increaseVerification : boolean

    /** Give a role automatically to new members. Set to 'off' to disable. */
    autoRole : string
  }
}

declare module 'azarasi/lib/guilds' {
  interface GuildData {
    /** Is the anti-raid currently active? */
    antiRaidTriggered : boolean
    /** Users associated with the current raid (id->timestamp) */
    antiRaidUsers? : AntiRaidUserEntry[]
    /** Keep track of the verification level active before triggering the anti-raid, in order to restore it */
    antiRaidPreviousVerificationLevel : number
  }
}

/**
 * Greet module.
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 **/
import { Azarasi } from 'azarasi'
import { Locale } from 'azarasi/lib/locales'
import { Settings } from 'azarasi/lib/settings'
import Discord from 'discord.js'
import moment from 'moment'

export default class Greet extends Azarasi.Module {
  init() {
    this.registerParameter('greetChannel', { type: Discord.TextChannel })
    this.registerParameter('greet', { type: String, min: 1, def: 'off' })
    this.registerParameter('farewell', { type: String, min: 1, def: 'off' })
    // Greeting message
    this.registerEvent('discord.guildMemberAdd', async (member : Discord.GuildMember) => {
      const s = await this.az.settings.getForGuild(member.guild)
      const l = this.az.locales.getLocale(s.locale!)
      if (!s.greet || s.greet === 'off') return
      const channel = this.getGreetChannel(member.guild, s)
      const vars = this.generateVars(member, l!)
      channel.send(this.transformTemplate(s.greet, vars))
    })
    // Farewell message
    this.registerEvent('discord.guildMemberRemove', async (member : Discord.GuildMember) => {
      const s = await this.az.settings.getForGuild(member.guild)
      const l = this.az.locales.getLocale(s.locale!)
      if (!s.farewell || s.farewell === 'off') return
      const channel = this.getGreetChannel(member.guild, s)
      const vars = this.generateVars(member, l!)
      channel.send(this.transformTemplate(s.farewell, vars))
    })
  }
  /** Transforms text input replacing variable templates */
  transformTemplate (template : string, vars : ITemplateVars) : string {
    return template.replace(/{\S+}/g, v => vars[v.slice(1, -1)] || v)
  }
  /** Generates variables that may be used in the welcome messages */
  generateVars (member : Discord.GuildMember, l : Locale) : ITemplateVars {
    return {
      id: member.id,
      name: member.displayName,
      username: member.user.username,
      discrim: member.user.discriminator,
      discriminator: member.user.discriminator,
      server: member.guild.name,
      guild: member.guild.name,
      mention: member.toString(),
      accountCreated: l.moment(member.user.createdAt).fromNow(true),
      tag: member.user.tag,
      avatar: member.user.avatarURL
    }
  }
  /** Attempts to pick the channel where messages will be sent */
  getGreetChannel (guild : Discord.Guild, s : Settings) : Discord.TextChannel {
    if (s.greetChannel) {
      const c = guild.channels.get(s.greetChannel) as Discord.TextChannel
      if (c) return c
    }
    if (guild.systemChannel) return guild.systemChannel as Discord.TextChannel
    if (guild.defaultChannel) return guild.defaultChannel
    return guild.channels.find(c => c.type === 'text') as Discord.TextChannel
  }
}

interface ITemplateVars {
  [key : string] : string
}

// Additional settings parameters
// TODO: Find a better way to do this
declare module 'azarasi/lib/settings' {
  interface Settings {
    /** Greeting message */
    greet : string
    /** Farewell message */
    farewell : string
    /** Channel to use for greeting and farewell messages */
    greetChannel : string
  }
}

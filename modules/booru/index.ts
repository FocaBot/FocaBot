/**
 * Booru Module
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 */
import { Azarasi } from 'azarasi'
import { DMChannel, GroupDMChannel } from 'discord.js'
import {
  IBooruProvider,
  Danbooru,
  Konachan,
  SankakuComplex,
  Yandere
} from './providers'

export default class Booru extends Azarasi.Module {
  providers : IBooruProvider[] = []
  /** Blacklisted tags **/
  tagBlacklist = ['loli', 'rori', 'shota', 'lolicon', 'toddlercon']

  init () {
    this.providers.push(new Danbooru(this.az)) // Danbooru
    this.providers.push(new Danbooru(this.az, true)) // Safebooru
    this.providers.push(new Konachan(this.az)) // Konachan.com
    this.providers.push(new Konachan(this.az, true)) // Konachan.net (safe mode)
    this.providers.push(new SankakuComplex(this.az)) // Sankaku Complex
    this.providers.push(new Yandere(this.az)) // Yande.re

    // Register commands
    for (const provider of this.providers) {
      this.registerCommand(provider.name, { allowDM: true, aliases: provider.aliases }, async ({ msg, args, s, l }) => {
        const nsfw = s.allowNSFW ||
          msg.channel instanceof DMChannel ||
          msg.channel instanceof GroupDMChannel ||
          msg.channel.nsfw
        const tags = args as string

        if (this.checkTagBlacklist(tags)) {
          // Query contains blacklisted tags, calling the authorities...
          return msg.reply('',{ embed: {
            image: {
              url: 'https://cdn.discordapp.com/attachments/244581077610397699/315655455143886850/Screenshot_from_2017-05-20_21-01-03.png'
            }
          }})
        }

        try {
          const post = await provider.getRandomPost(tags, nsfw)
          // Send the picture
          return msg.reply('', { embed: {
            title: l!.generic.sauceBtn,
            url: post.webUrl,
            image: { url: post.embedUrl }
          }})
        } catch (e) {
          if (e.statusCode && e.statusCode === 404) return msg.reply(l!.generic.noResults)
          this.az.logError(e)
          return msg.reply(l!.generic.error)
        }
      })
    }
  }

  /** Check if there are blacklisted tags in the query **/
  checkTagBlacklist (tags : string) {
    return !!tags.split(' ').find(tag => this.tagBlacklist.indexOf(tag) >= 0)
  }
}

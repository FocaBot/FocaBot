/**
 * Image module.
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 **/
import { Azarasi } from 'azarasi'
import {
  IPictureProvider,
  Giphy,
  Google,
  Imgur
} from './providers'
import { DMChannel, GroupDMChannel } from "discord.js"

export default class Index extends Azarasi.Module {
  providers : IPictureProvider[] = []
  // Literally a copy-paste from the Booru module, might merge them in the future.
  init() {
    this.providers.push(new Giphy(this.az))
    this.providers.push(new Google(this.az))
    this.providers.push(new Imgur(this.az))

    for (const provider of this.providers) {
      this.registerCommand(provider.name, { allowDM: true, aliases: provider.aliases }, async ({ msg, args, s, l }) => {
        try {
          const nsfw = s.allowNSFW ||
            msg.channel instanceof DMChannel ||
            msg.channel instanceof GroupDMChannel ||
            msg.channel.nsfw
          const query = args as string

          const image = await provider.getRandomImage(query, nsfw)
          // Send the picture
          return msg.reply('', { embed: {
              title: l!.generic.sauceBtn,
              url: image.webUrl,
              image: { url: image.embedUrl }
            }})
        } catch (e) {
          if (e.statusCode && e.statusCode === 404) return msg.reply(l!.generic.noResults)
          this.az.logError(e)
          return msg.reply(l!.generic.error)
        }
      })
    }
  }
}


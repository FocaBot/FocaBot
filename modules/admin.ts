/**
 * Admin module.
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 **/
import { Azarasi } from 'azarasi'
import { exec } from 'child_process'
import os from 'os'

export default class Admin extends Azarasi.Module {
  allowDisabling = false
  init() {
    // Properties for admin only commands
    const admin = { adminOnly: true }
    // Properties for owner only commands
    const owner = { ownerOnly: true, allowDM: true }

    // Changes the bot's nickname in a guild
    this.registerCommand('setnick', admin, async ({ msg, args, l }) => {
      try {
        await msg.guild.member(this.bot.user).setNickname(args.toString())
        msg.reply(l!.admin.nickChanged)
      } catch (e) {
        this.az.log(e)
        msg.reply(l!.generic.error)
      }
    })
    // Deletes recent bot messages (and invocations)
    this.registerCommand('clean', admin, async ({ msg, args, l, settings }) => {
      try {
        const messages = await msg.channel.fetchMessages({ limit: 100 })
        // Get only the messages from the bot and starting with the bot's prefix
        const botMessages = messages.filterArray(m =>
          m.author.id === this.bot.user.id ||
          m.content.indexOf(this.az.properties.prefix || '') === 0 ||
          m.content.indexOf(settings.prefix || '') === 0
        )
        if (!botMessages.length) return
        await msg.channel.bulkDelete(botMessages)
      } catch (e) {
        this.az.logError(e)
        msg.reply(l!.admin.cantDelete)
      }
    })
    // Deletes last X messages
    this.registerCommand('purge', {...admin, argSeparator: ' ' }, async ({ msg, args, l }) => {
      const limit = parseInt(args[0])
      if (!isFinite(limit) || limit <= 0) return msg.reply(l!.generic.invalidArgs)
      try {
        let messages = await msg.channel.fetchMessages({ limit })
        if (msg.mentions.members.first()) {
          messages = messages.filter(m => m.member.id === msg.mentions.members.first().id)
        }
        await msg.channel.bulkDelete(messages)
      } catch (e) {
        this.az.logError(e)
        msg.reply(l!.admin.cantDelete)
      }
    })
    // Changes settings parameters for a guild
    this.registerCommand('config', {...admin, argSeparator: ' ' }, async ({ msg, args, l, settings }) => {
      const param = args[0]
      const value = (args as string[]).slice(1).join(' ')
      // List settings if no parameter is specified
      if (!param) return msg.reply('', {
        embed: {
          description: Object.keys(settings).map((k) => `**${k}:** ${settings[k]}`).join('\n')
        }
      })
      // Check if parameter exists in schema
      if (!this.az.settings.schema.get(param)) return msg.reply(l!.config.invalidParameter)
      // Update parameter value
      if (value) {
        try {
          await this.az.settings.setGuildParam(msg.guild, param, value)
        } catch (e) {
          return msg.reply(l!.config.invalidValue, { embed: {
            color: 0xEE0000,
            description: e.message || e,
          }})
        }
      }
      // Display parameter parameter value
      msg.channel.send('', { embed: {
        fields: [
          { name: l!.config.parameter, value: param, inline: true },
          {
            name: l!.config.value,
            value: (await this.az.settings.getGuildParam(msg.guild, param)).toString(),
            inline: true
          }
        ]
      }})
    })
    // Enables a module for the current guild
    this.registerCommand('enable', admin, async ({ msg, args, l }) => {
      const module = args.toString()
      if (!this.az.modules.get(module)) return msg.reply(l!.admin.noSuchModule)
      try {
        await this.az.modules.enableModuleForGuild(msg.guild, module)
        msg.reply(l!.generic.success)
      } catch (e) {
        msg.reply(l!.generic.error)
      }
    })
    // Disables a module for the current guild
    this.registerCommand('disable', admin, async ({ msg, args, l }) => {
      const module = args.toString()
      if (!this.az.modules.get(module)) return msg.reply(l!.admin.noSuchModule)
      try {
        await this.az.modules.disableModuleForGuild(msg.guild, module)
        msg.reply(l!.generic.success)
      } catch (e) {
        msg.reply(l!.generic.error)
      }
    })
    // Change command permissions
    // this.registerCommand('perm', admin, ...)

    // Owner only commands

    // Restart the bot
    // this.registerCommand('restart', owner, ...)

    // Execute shell command
    this.registerCommand('exec', owner, ({ msg, args }) => new Promise((resolve, reject) =>{
      exec(args.toString(), (e, stdout, stderr) => {
        if (e) return reject(e)
        resolve(msg.channel.send(
          '```diff\n' +
          `! [focaBot@${os.hostname()} ~] ${args}\n\n` +
          stdout + '\n' +
          stderr.replace(/^/gm, '- ') + '\n```'
        ))
      })
    }))
    // Update bot
    // this.registerCommand('update', owner, ...)

    // Change avatar
    this.registerCommand('setavatar', owner, async ({ msg, args, l }) => {
      try {
        if (msg.attachments.first()) await this.bot.user.setAvatar(msg.attachments.first().url)
        else await this.bot.user.setAvatar(args.toString())
      } catch (e) {
        msg.reply(l!.generic.error)
        this.az.logError(e)
      }
    })
    // Change username
    this.registerCommand('setusername', owner, async ({ msg, args, l }) => {
      try {
        await this.bot.user.setUsername(args.toString())
        msg.reply(l!.admin.usernameChanged)
      } catch (e) {
        this.az.logError(e)
        msg.reply(l!.generic.error)
      }
    })
    // Blacklist user
    // this.registerCommand('blacklist', owner, ...)
    // Unblacklist user
    // this.registerCommand('unblacklist', owner, ...)
    // Load module
    this.registerCommand('load', {...owner, argSeparator: ',' }, ({ msg, args, l }) => {
      try {
        this.az.modules.load(args)
        msg.reply(l!.generic.success)
      } catch (e) {
        msg.channel.send({
          embed: {
            color: 0xFF0000,
            description: e.message || 'Something went wrong.'
          }
        })
      }
    })
    // Unload module
    this.registerCommand('unload', {...owner, argSeparator: ',' }, ({ msg, args, l }) => {
      try {
        this.az.modules.unload(args)
        msg.reply(l!.generic.success)
      } catch (e) {
        msg.channel.send({
          embed: {
            color: 0xFF0000,
            description: e.message || 'Something went wrong.'
          }
        })
      }
    })
    // Reload module
    this.registerCommand('reload', {...owner, argSeparator: ',' }, ({ msg, args, l }) => {
      try {
        this.az.modules.reload(args)
        msg.reply(l!.generic.success)
      } catch (e) {
        msg.channel.send({
          embed: {
            color: 0xFF0000,
            description: e.message || 'Something went wrong.'
          }
        })
      }
    })
  }
}

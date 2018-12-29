/**
 * Admin module.
 * @author TheBITLINK aka BIT <me@thebitlink.com>
 * @license MIT
 **/
import { Azarasi, CommandContext } from 'azarasi'
import { registerCommand } from 'azarasi/lib/decorators'
import { exec } from 'child_process'
import os from 'os'

export default class Admin extends Azarasi.Module {
  allowDisabling = false

  /**
   * Changes the bot's nickname in a guild
   * @parameter nickname - New nickname
   */
  @registerCommand({ adminOnly: true })
  async setNick ({ msg, l } : CommandContext, nickname : string) {
    try {
      await msg.guild.member(this.bot.user).setNickname(nickname)
      msg.reply(l!.admin.nickChanged)
    } catch (e) {
      this.az.log(e)
      msg.reply(l!.generic.error)
    }
  }

  /**
   * Deletes recent bot messages (and most invocations).
   */
  @registerCommand({ adminOnly: true })
  async clean ({ msg, l, settings } : CommandContext) {
    try {
      const messages = await msg.channel.fetchMessages({ limit: 100 })
      // Get only the messages from the bot and starting with the bot's prefix
      // TODO: Get mentions as well (and possibly regex triggers?)
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
  }

  /**
   * Deletes last X messages.
   * Can optionally mention a user to remove only theirs.
   * @param messageLimit - Number of messages to delete. Only 100 messages at a time are allowed by the API.
   */
  @registerCommand({ adminOnly: true, argSeparator: ' ' })
  async purge ({ msg, l } : CommandContext, messageLimit : string) {
    const limit = parseInt(messageLimit)
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
  }

  /**
   * Changes settings parameters for a guild
   * @param param - Parameter to change
   * @param value - New value
   */
  @registerCommand({ adminOnly: true, argSeparator: ' ' })
  async config ({ msg, l, settings } : CommandContext, param : string, ...value : string[]) {
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
  }

  /**
   * Enables a module for the current guild.
   * @param module - Module to enable
   */
  @registerCommand({ adminOnly: true })
  async enable ({ msg, l } : CommandContext, module : string) {
    if (!this.az.modules.get(module)) return msg.reply(l!.admin.noSuchModule)
    try {
      await this.az.modules.enableModuleForGuild(msg.guild, module)
      msg.reply(l!.generic.success)
    } catch (e) {
      msg.reply(l!.generic.error)
    }
  }

  /**
   * Disables a module for the current guild.
   * @param module - Module to disable
   */
  @registerCommand({ adminOnly: true })
  async disable ({ msg, l } : CommandContext, module : string) {
    if (!this.az.modules.get(module)) return msg.reply(l!.admin.noSuchModule)
    try {
      await this.az.modules.disableModuleForGuild(msg.guild, module)
      msg.reply(l!.generic.success)
    } catch (e) {
      msg.reply(l!.generic.error)
    }
  }

  // TODO: perm, update, blacklist and restart commands

  /**
   * Execute shell command.
   * @param cmd - Command to execute
   */
  @registerCommand({ ownerOnly: true, allowDM: true })
  exec ({ msg } : CommandContext, cmd : string) {
    return new Promise((resolve, reject) => {
      exec(cmd, (e, stdout, stderr) => {
        if (e) return reject(e)
        resolve(msg.channel.send(
          '```diff\n' +
          `! [focaBot@${os.hostname()} ~] ${cmd}\n\n` +
          stdout + '\n' +
          stderr.replace(/^/gm, '- ') + '\n```'
        ))
      })
    })
  }

  /**
   * Changes the bot's avatar image.
   * @param avatarURL - Avatar URL to use if no attachment is present
   */
  @registerCommand({ ownerOnly: true, allowDM: true })
  async setAvatar ({ msg, l } : CommandContext, avatarURL : string) {
    try {
      if (msg.attachments.first()) await this.bot.user.setAvatar(msg.attachments.first().url)
      else await this.bot.user.setAvatar(avatarURL)
    } catch (e) {
      msg.reply(l!.generic.error)
      this.az.logError(e)
    }
  }

  /**
   * Changes the bot's username.
   * @param username - New username
   */
  @registerCommand({ ownerOnly: true, allowDM: true })
  async setUsername ({ msg, l } : CommandContext, username : string) {
    try {
      await this.bot.user.setUsername(username)
      msg.reply(l!.admin.usernameChanged)
    } catch (e) {
      this.az.logError(e)
      msg.reply(l!.generic.error)
    }
  }

  /**
   * Loads a module at runtime.
   * @param module - Module to load
   */
  @registerCommand({ ownerOnly: true, allowDM: true })
  load ({ msg, l } : CommandContext, module : string) {
    try {
      this.az.modules.load(module)
      msg.reply(l!.generic.success)
    } catch (e) {
      msg.channel.send({
        embed: {
          color: 0xFF0000,
          description: e.message || 'Something went wrong.'
        }
      })
    }
  }

  /**
   * Unloads a module at runtime.
   * @param module - Module to unload
   */
  @registerCommand({ ownerOnly: true, allowDM: true })
  unload ({ msg, l } : CommandContext, module : string) {
    try {
      this.az.modules.unload(module)
      msg.reply(l!.generic.success)
    } catch (e) {
      msg.channel.send({
        embed: {
          color: 0xFF0000,
          description: e.message || 'Something went wrong.'
        }
      })
    }
  }

  /**
   * Reloads a module at runtime.
   * @param module - Module to reload
   */
  @registerCommand({ ownerOnly: true, allowDM: true })
  reload ({ msg, l } : CommandContext, module : string) {
    try {
      this.az.modules.reload(module)
      msg.reply(l!.generic.success)
    } catch (e) {
      msg.channel.send({
        embed: {
          color: 0xFF0000,
          description: e.message || 'Something went wrong.'
        }
      })
    }
  }
}

reload = require('require-reload')(require)
childProcess = require 'child_process'
os = require 'os'
request = require 'request'
Discord = require 'discord.js'
ytdl = require 'ytdl-getinfo'
Blacklist = require './blacklist'

class AdminModule extends BotModule
  init: ->
    blacklist = new Blacklist
    blacklist.init()
    
    #
    # Admin only commands
    #
    admin = adminOnly: true
    # Changes the nickname
    @registerCommand 'setnick', admin, ({ msg, args, locale })=>
      try
        await msg.guild.member(Core.bot.user).setNickname(args)
        msg.reply locale.admin.nickChanged
      catch e
        Core.log(e, 1)
        msg.reply locale.generic.error
    # Deletes recent bot messages
    @registerCommand 'clean', admin, ({ msg, args, locale, settings })=>
      try
        messages = await msg.channel.fetchMessages { limit: 100 }
        # Get only the messages from the bot and starting with the bot's prefix.
        botMessages = messages.filterArray (m)=>
          (m.author.id is Core.bot.user.id) or
          (m.content.indexOf(Core.properties.prefix) is 0) or
          (m.content.indexOf(settings.prefix) is 0)
        await msg.channel.bulkDelete(botMessages)
      catch e
        Core.log(e, 1)
        msg.reply locale.admin.cantDelete
    @registerCommand 'purge', admin, ({ msg, args, locale })=>
      limit = parseInt(args)
      if isFinite(limit) and limit > 0
        try
          messages = await msg.channel.fetchMessages { limit }
          await msg.channel.bulkDelete(messages)
        catch e
          Core.log(e, 1)
          msg.reply locale.admin.cantDelete
      else msg.reply locale.generic.invalidArgs
    @registerCommand 'config', admin, ({ msg, args, locale, settings })=>
      param = args.split(' ')[0]
      value = args.split(' ')[1..].join(' ')
      return msg.reply locale.generic.noParameter unless param
      return msg.reply locale.config.invalidParameter unless Core.settings.schema[param]
      if value
        try
          await Core.settings.setGuildParam(msg.guild, param, value)
        catch e
          return msg.reply locale.config.invalidValue, embed: {
            color: 0xEE0000
            description: e.message
          }
      msg.channel.send '', embed: fields: [
        { name: locale.config.parameter, value: param, inline: true }
        {
          name: locale.config.value
          value: (await Core.settings.getGuildParam(msg.guild, param)).toString()
          inline: true
        }
      ]
    @registerCommand 'enable', admin, ({ msg, args, locale })=>
      return msg.reply locale.admin.noSuchModule unless Core.modules.loaded[args]
      try
        await Core.modules.enableForGuild(msg.guild, args)
        msg.reply locale.generic.success
      catch e
        msg.reply locale.generic.error
    @registerCommand 'disable', admin, ({ msg, args, locale })=>
      return msg.reply locale.admin.noSuchModule unless Core.modules.loaded[args]
      try
        await Core.modules.disableForGuild(msg.guild, args)
        msg.reply locale.generic.success
      catch e
        msg.reply locale.generic.error
    @registerCommand 'perm', admin, ({ msg, args, locale, data, save })=>
      cmd = Core.commands.registered[args.split(' ')[0]]
      lvl = args.split(' ')[1]
      return msg.reply locale.admin.noSuchCommand unless cmd and not cmd.ownerOnly
      return msg.reply locale.admin.invalidLevel unless lvl in ['*', 'dj', 'admin']
      data.permissionOverrides = {} unless data.permissionOverrides
      data.permissionOverrides[cmd.name] = lvl
      await save()
      msg.reply locale.admin.permissionsUpdated
    #
    # Owner Only Commands
    #
    owner = ownerOnly: true, allowDM: true
    @registerCommand 'restart', owner, ({ msg, args, locale })=>
      # NOTE: THE RESTART COMMAND JUST RUNS process.exit()
      # IT ASSUMES YOU ARE USING A PROCESS MANAGER (PM2, forever, systemd, nodemon, etc)
      # TO BRING THE BOT BACK UP AUTOMATICALLY
      await msg.channel.send locale.admin.restarting
      if args.toLowerCase() is 'global'
        # Trigger a global restart
        shardManager = new Discord.ShardClientUtil(Core.bot)
        shardManager.broadcastEval('process.exit()')
      # Only restart current shard
      else process.exit()
    # Executes a shell command and sends the output
    @registerCommand 'exec', owner, ({ msg, args })=> new Promise (resolve, reject)=>
      childProcess.exec args, (error, stdout, stderr)->
        return reject(error) if error
        resolve msg.channel.send """
        ```diff
        ! [focaBot@#{os.hostname()} ~]$ #{args}

        #{stdout}#{stderr.replace(/^/gm, '- ')}
        ```
        """
    # Runs git pull and updates youtube-dl, then restarts the bot.
    @registerCommand 'update', owner, ({ msg, args, locale })=>
      msg.channel.send locale.admin.updating
      # TODO: update using npm as well
      try Core.commands.run('exec', msg, 'git pull')
      catch e
        Core.log(e, 1)
      # Update youtube-dl
      msg.channel.send locale.admin.ytdlUpdate
      try
        ytdlVersion = await ytdl.update()
        msg.channel.send locale.gen(locale.admin.ytdlUpdated, ytdlVersion)
      catch e
        Core.log(e, 1)
        msg.channel.send locale.admin.ytdlUpdateError
      # Restart the bot
      unless args.toLowerCase() is 'norestart'
        Core.commands.run('restart', msg, args)
    @registerCommand 'setavatar', owner, ({ msg, args, locale })=>
      try
        if msg.attachments.first()
          await Core.bot.user.setAvatar(msg.attachments.first().url)
        else
          await Core.bot.user.setAvatar(args)
        msg.reply locale.admin.avatarChanged
      catch e
        Core.log(e, 1)
        msg.reply locale.generic.error
    @registerCommand 'setusername', owner, ({ msg, args, locale })=>
      try
        await Core.bot.user.setUsername(args)
      catch e
        Core.log(e, 1)
        msg.reply locale.generic.error
    @registerCommand 'blacklist', owner, ({ msg, args, locale })=>
      return msg.reply locale.admin.noUserSpecified unless msg.mentions.users.first()
      u = msg.mentions.users.first()
      await blacklist.add(u)
      return msg.reply locale.gen locale.admin.blacklistAdd,
                                  "#{u.username}##{u.discriminator}"
    @registerCommand 'unblacklist', owner, ({ msg, args, locale })=>
      return msg.reply locale.admin.noUserSpecified unless msg.mentions.users.first()
      u = msg.mentions.users.first()
      await blacklist.remove(u)
      return msg.reply locale.gen locale.admin.blacklistRemove,
                                  "#{u.username}##{u.discriminator}"

    #
    # Module related commands
    #
    module = ownerOnly: true, allowDM: true, argSeparator: ','
    # Load module(s)
    @registerCommand 'load', module, ({ msg, args, locale })=>
      try
        Core.modules.load(args)
        msg.reply locale.generic.success
    @registerCommand 'unload', module, ({ msg, args, locale })=>
      try
        Core.modules.unload(args)
        msg.reply locale.generic.success
    @registerCommand 'reload', module, ({ msg, args, locale })=>
      try
        Core.modules.reload(args)
        msg.reply locale.generic.success

module.exports = AdminModule

childProcess = require 'child_process'
os = require 'os'
request = require 'request'

class AdminModule extends BotModule
  init: =>
    {@getGuildData, @permissions} = @engine
    # Admin Commands
    adminOptions =
      adminOnly: true
    @registerCommand 'setnick', adminOptions, @setnickFunc
    @registerCommand 'clean', adminOptions, @cleanFunc
    @registerCommand 'reset', adminOptions, @resetFunc
    @registerCommand 'config', { argSeparator: ' ', adminOnly: true }, @configFunc
    # Restart Command
    ownerOptions =
      ownerOnly: true
      allowDM: true
    @registerCommand 'restart', ownerOptions, @restartFunc
    @registerCommand 'update', ownerOptions, @updateFunc
    @registerCommand 'pull', ownerOptions, @pullFunc
    @registerCommand 'exec', ownerOptions, @execFunc
    @registerCommand 'purge', ownerOptions, @purgeFunc
    @registerCommand 'find', @findFunc
    @registerCommand 'setavatar', ownerOptions, @setavatarFunc
    @registerCommand 'setusername', ownerOptions, @setusernameFunc

  setnickFunc: (msg, args)=>
    @bot.User.memberOf(msg.guild).setNickname args
    .then ()=>
      msg.reply "Nickname changed succesfully!"
    .catch (error)=>
      console.error error
      msg.reply "Couldn't set nickname for the bot. Make sure it has enough permissions."

  setusernameFunc: (msg, args)=>
    @bot.User.setUsername args
    .then => msg.reply 'Username changed.'
    .catch => msg.reply "Couldn't change the username."

  setavatarFunc: (msg,args)=>
    return if not msg.attachments[0]
    request { url: msg.attachments[0].url, encoding: null }, (error, response, body)=>
      @bot.User.setAvatar body if not error and response.statusCode == 200

  configFunc: (msg, args, d)=>
    if not args[0]
      return msg.channel.sendMessage """
      **Usage: #{d.data.prefix or @engine.prefix}config <parameter> [value]**
      Example:
      ```#{d.data.prefix or @engine.prefix}config restrict yes```
      Parameters (case sensitive):
      **prefix**: <text> - Prefix to use on this server.
      **restrict**: <yes/no> - When enabled, only DJs and Bot Commanders have access to the bot.
      **autoDel**: <yes/no> - When enabled, the bot deletes some messages automatically.
      **allowNSFW**: <yes/no> - When disabled, the commands `imgn` and `rimgn` can't be used.
      """
    switch args[0]
      when 'prefix'
        if args[1]
          if args[1].length <= 5
            d.data.prefix = args[1]
            d.data.save().then => msg.reply 'Settings Saved!'
          else msg.reply "The prefix length can't exceed 5 character."
        else msg.reply """
        Current prefix for this server: #{d.data.prefix or @engine.prefix}
        Default prefix: #{@engine.prefix}
        """
      when 'restrict'
        if args[1]
          switch args[1]
            when 'on', 'true', '1', 'yes', 'y'
              d.data.restricted = true
              d.data.save().then => msg.reply 'Settings Saved!'
            when 'off', 'false', '0', 'no', 'n'
              d.data.restricted = false
              d.data.save().then => msg.reply 'Settings Saved!'
            else msg.reply "Invalid value (#{args[1]}). Please use either `yes` or `no`."
        else
          return msg.reply "#{@engine.name} is currently restricted on this server." if d.data.restricted
          msg.reply "#{@engine.name} is not restricted on this server."
      when 'autoDel'
        if args[1]
          switch args[1]
            when 'on', 'true', '1', 'yes', 'y'
              d.data.autoDel = true
              d.data.save().then => msg.reply 'Settings Saved!'
            when 'off', 'false', '0', 'no', 'n'
              d.data.autoDel = false
              d.data.save().then => msg.reply 'Settings Saved!'
            else msg.reply "Invalid value (#{args[1]}). Please use either `yes` or `no`."
        else
          return msg.reply "Messages sent by the bot are being auto deleted." if d.data.autoDel
          msg.reply "Messages sent by the bot are not being auto deleted."
      when 'allowNSFW'
        if args[1]
          switch args[1]
            when 'on', 'true', '1', 'yes', 'y'
              d.data.allowNSFW = true
              d.data.save().then => msg.reply 'Settings Saved!'
            when 'off', 'false', '0', 'no', 'n'
              d.data.allowNSFW = false
              d.data.save().then => msg.reply 'Settings Saved!'
            else msg.reply "Invalid value (#{args[1]}). Please use either `yes` or `no`."
        else
          return msg.reply "NSFW commands are allowed." if d.data.allowNSFW
          msg.reply "NSFW commands are not allowed."
      else msg.reply "Unrecognized parameter #{args[0]}."

  restartFunc: (msg)=>
    msg.channel.sendMessage 'FocaBot is restarting...'
    .then ()-> process.exit() # Let's hope PM2 restarts it :)

  updateFunc: (msg,args,d,bot)=>
      @pullFunc msg,args,bot
      .then ()=> @restartFunc msg,args,bot

  pullFunc: (msg,args,d,bot)=> @execFunc msg, 'git pull', bot

  execFunc: (msg, args, bot)=>
    childProcess.exec args, (error, stdout, stderr)->
      msg.channel.sendMessage """
                              ```diff
                              + [focaBot@#{os.hostname()} ~]$ #{args}

                              #{stdout}
                              ```
                              """

  cleanFunc: (msg,args,d,bot)=>
    hasError = false
    bot.Messages.deleteMessages(msg.channel.messages.filter((m)=>
      m.author.id is bot.User.id or m.content.indexOf(@engine.prefix) is 0
    ).slice(0 - (parseInt(args) or 50)))
    .catch =>
      msg.channel.sendMessage "Couldn't delete some messages."

  purgeFunc: (msg, args, d, bot)=>
    limit = parseInt(args) or 50
    msg.channel.fetchMessages limit
    .then (e)=> bot.Messages.deleteMessages e.messages

  findFunc: (msg, args, d, bot)=>
    return if not msg.author.id in ['188487822238416896', '226875158479110144'] and not @permissions.isOwner msg.author
    rp = ""
    msgs =  bot.Messages.filter (m)=>
      m.content.indexOf(args) >= 0 and
      m.guild.id is msg.guild.id and
      m.author.id isnt msg.author.id and
      m.author.id isnt bot.User.id
    .slice 0,10
    rp = "#{msg.member.mention} here's what i found for `#{args}`:\n"
    for ms in msgs
      rp += "__(deleted)__ " if ms.deleted
      rp += "**#{ms.author.username}**: #{ms.content}\n"
    msg.channel.sendMessage rp

  resetFunc: (msg, args)=>
    @getGuildData msg.guild
    .then (data)=>
      data.queue.clearQueue()
      try
        msg.member.getVoiceChannel().leave()

module.exports = AdminModule

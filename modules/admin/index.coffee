childProcess = require 'child_process'
os = require 'os'
request = require 'request'
Blacklist = require './blacklist'

class AdminModule extends BotModule
  init: =>
    { @permissions } = @engine
    @blacklist = new Blacklist
    @blacklist.init()
    # Admin Commands
    adminOptions =
      adminOnly: true
    @registerCommand 'setnick', adminOptions, @setnickFunc
    @registerCommand 'clean', adminOptions, @cleanFunc
    @registerCommand 'reset', adminOptions, @resetFunc
    # Restart Command
    ownerOptions =
      ownerOnly: true
      allowDM: true
    @registerCommand 'restart', ownerOptions, @restartFunc
    @registerCommand 'update', ownerOptions, @updateFunc
    @registerCommand 'pull', ownerOptions, @pullFunc
    @registerCommand 'exec', ownerOptions, @execFunc
    @registerCommand 'purge', ownerOptions, @purgeFunc
    @registerCommand 'setavatar', ownerOptions, @setavatarFunc
    @registerCommand 'setusername', ownerOptions, @setusernameFunc
    @registerCommand 'blacklist', ownerOptions, @blacklistFunc
    @registerCommand 'unblacklist', ownerOptions, @unblacklistFunc

  setnickFunc: (msg, args)=>
    @bot.User.memberOf(msg.guild).setNickname args
    .then ()=>
      msg.reply 'Nickname changed succesfully!'
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

  restartFunc: (msg)=>
    msg.channel.sendMessage 'FocaBot is restarting...'
    .then ()-> childProcess.exec('pm2 restart focaBot')

  updateFunc: (msg,args,d,bot)=>
    @pullFunc msg, args, bot
    .then ()=> @restartFunc msg,args,bot

  pullFunc: (msg,args,d,bot)=> @execFunc msg, 'git pull', bot

  execFunc: (msg, args, bot)=> new Promise (resolve)=>
    childProcess.exec args, (error, stdout, stderr)->
      if stderr then stderr = '\n-' + stderr
      msg.channel.sendMessage """
                              ```diff
                              + [focaBot@#{os.hostname()} ~]$ #{args}

                              #{stdout}#{stderr}
                              ```
                              """
      resolve()

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

  blacklistFunc: (msg)=>
    return msg.reply 'No user specified' unless msg.mentions[0]
    u = msg.mentions[0]
    await @blacklist.add(u)
    return msg.reply "Successfully blacklisted **#{u.username}##{u.discriminator}**."

  unblacklistFunc: (msg)=>
    return msg.reply 'No user specified' unless msg.mentions[0]
    u = msg.mentions[0]
    await @blacklist.remove(u)
    return msg.reply """
    Successfully removed **#{u.username}##{u.discriminator}** from the blacklist.
    """

module.exports = AdminModule

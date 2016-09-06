childProcess = require 'child_process'
os = require 'os'
request = require 'request'

class AdminModule extends BotModule
  init: =>
    # Admin Commands
    adminOptions =
      adminOnly: true
    @registerCommand 'setnick', adminOptions, @setnickFunc
    @registerCommand 'clean', adminOptions, @cleanFunc
    # Restart Command
    ownerOptions =
      ownerOnly: true
    @registerCommand 'restart', ownerOptions, @restartFunc
    @registerCommand 'update', ownerOptions, @updateFunc
    @registerCommand 'pull', ownerOptions, @pullFunc
    @registerCommand 'exec', ownerOptions, @execFunc
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

  restartFunc: (msg)=>
    msg.channel.sendMessage 'FocaBot is restarting...'
    .then ()-> process.exit() # Let's hope PM2 restarts it :)

  updateFunc: (msg,args,bot)=>
      @pullFunc msg,args,bot
      .then ()=> @restartFunc msg,args,bot

  pullFunc: (msg,args,bot)=> @execFunc 'git pull', args, bot

  execFunc: (msg, args, bot)=>
    childProcess.exec args, (error, stdout, stderr)->
      msg.channel.sendMessage """
                              ```diff
                              + [#{@engine.name}@#{os.hostname()} ~]$ #{args}

                              #{stdout}
                              ```
                              """

  cleanFunc: (msg,args,bot)=>
    hasError = false
    bot.Messages.deleteMessages msg.channel.messages.filter (m)=>
      m.author.id is bot.User.id or m.content.indexOf @engine.prefix is 0
    .catch =>
      msg.channel.sendMessage "Couldn't delete some messages."

module.exports = AdminModule
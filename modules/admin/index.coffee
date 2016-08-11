childProcess = require 'child_process'

class AdminModule
  constructor: (@engine)->
    {@bot, @commands, @serverData, @prefix} = @engine
    # Admin Commands
    adminOptions =
      adminOnly: true
    @setnickCommand =  @commands.registerCommand 'setnick', adminOptions, @setnickFunc
    @enableCommand =  @commands.registerCommand 'enable', adminOptions, @enableFunc
    @disableCommand =  @commands.registerCommand 'disable', adminOptions, @disableFunc
    @cleanCommand =  @commands.registerCommand 'clean', adminOptions, @cleanFunc
    # Restart Command
    restartOptions =
      ownerOnly: true
    @restartCommand = @commands.registerCommand 'restart', restartOptions, @restartFunc
    @updateCommand = @commands.registerCommand 'update', restartOptions, @updateFunc
    @pullCommand = @commands.registerCommand 'pull', pullOptions, @pullFunc

  setnickFunc: (msg, args)=>
    @bot.setNickname msg.server, args, @bot.user, (error)=>
      if error?
        @bot.sendMessage msg.channel "Couldn't set nickname for the bot. Make sure it has enough permissions."
      else
        @bot.sendMessage msg.channel "Nickname changed succesfully!"

  enableFunc: (msg)=>
    @serverData.servers[msg.server.id].enabled = true
    @bot.sendMessage msg.channel, 'FocaBot enabled for this server.'

  disableFunc: (msg)=>
    @serverData.servers[msg.server.id].enabled = false
    @bot.sendMessage msg.channel, 'FocaBot disabled for this server (will only accept commands from Bot Commanders).'

  restartFunc: (msg)=>
    @bot.sendMessage msg.channel, 'FocaBot is restarting...'
    .then ()-> setTimeout process.exit, 2000 # Let's hope PM2 restarts it :)

  updateFunc: (msg,args,bot)=>
      @pullFunc msg,args,bot
      .then ()=> @restartFunc msg,args,bot

  pullFunc: (msg,args,bot)=> new Promise (resolve, reject)=>
    childProcess.exec 'git pull origin master', (error, stdout, stderr)->
      bot.sendMessage msg.channel, """
                       ```diff
                       + $ git pull origin master

                       """+stdout+"""
                       ```
                       """
      .then resolve

  cleanFunc: (msg,args,bot)=>
    hasError = false
    for m in msg.channel.messages when m.author is bot.user or (m.content.indexOf @prefix) is 0
      bot.deleteMessage m,{},(err)->
        if err and not hasError
          bot.sendMessage msg.channel, "Couldn't delete messages, check the bot permissions."
          hasError = true
      

  shutdown: =>
    @commands.unregisterCommands [@setnickCommand, @enableCommand, @disableCommand, @restartCommand, @updateCommand, @cleanCommand]

module.exports = AdminModule
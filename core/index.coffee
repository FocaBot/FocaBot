###
The Main Server Class
###
Discordie = require 'discordie'
CommandManager = require './commands'
ModuleManager = require './modules'
PermissionManager = require './permissions'
ServerManager = require './servers'
git = require 'git-rev'

class BotEngine
  constructor: (@settings) ->
    {@prefix, @name} = @settings
    @bot = new Discordie { autoReconnect: true }
    # @serverData = new ServerManager @
    @permissions = new PermissionManager @
    @commands = new CommandManager @
    @modules = new ModuleManager @
    @bot.Dispatcher.on 'GATEWAY_READY', @onReady
    @bot.Dispatcher.on 'MESSAGE_CREATE', @onMessage
    @bootDate = new Date()
    git.short @devVersion
    @version = "0.4.1"
    
  onReady: =>
    @bot.User.setGame "#{@prefix}help | #{@prefix}filters"
    console.log 'Connected.'

  onMessage: (e)=>
    if e.message.content[..@prefix.length-1] is @prefix
      @commands.executeCommand e.message

  devVersion: (version)=>
    @versionName = 'git-'+version

  establishConnection: => @bot.connect { token: @settings.token }

  getServerData: (server)=> @serverData.servers[server.id]

module.exports = BotEngine

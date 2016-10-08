###
The Main Server Class
###
Discordie = require 'discordie'
CommandManager = require './commands'
ModuleManager = require './modules'
PermissionManager = require './permissions'
GuildManager = require './guilds'
WebHookCollection = require './webHooks'
git = require 'git-rev'
# { Guild } = require '../models'

class BotEngine
  constructor: (@settings) ->
    {@prefix, @name} = @settings
    @bot = new Discordie { autoReconnect: true }
    @guildData = new GuildManager @
    @permissions = new PermissionManager @
    @commands = new CommandManager @
    @modules = new ModuleManager @
    @webHooks = new WebHookCollection @
    @bot.Dispatcher.on 'GATEWAY_READY', @onReady
    @bot.Dispatcher.on 'MESSAGE_CREATE', @onMessage
    @bootDate = new Date()
    git.short @devVersion
    @version = "dev-0.5.1"
    global.Core = @
    
  onReady: (e)=>
    @bot.User.setStatus 'dnd', {
      name: "'help [#{@version}]'"
    } 
    console.log 'Connected.'

  onMessage: (e)=>
    if e.message.content[..@prefix.length-1] is @prefix
      @commands.executeCommand e.message

  devVersion: (version)=>
    @versionName = 'git-'+version

  establishConnection: => @bot.connect { token: @settings.token }

  getGuildData: (guild)=>
    return @guildData.guilds[guild.id] if @guildData.guilds[guild.id]?
    @guildData.addGuild guild

module.exports = BotEngine

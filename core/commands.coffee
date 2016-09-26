# Represents a single command
class BotCommand
  constructor: (@engine, @name, opt, @func)->
    {@bot} = @engine
    {
      @aliases,
      @adminOnly,
      @djOnly,
      @ownerOnly,
      @argSeparator,
      @includeCommandNameInArgs
    } = opt
  
  exec: (msg, args)=>
    @func msg, args, @bot, @engine

# Manages all the commands
class BotCommandManager
  constructor: (@engine)->
    {@prefix, @bot, @permissions} = @engine
    @registered = {}
    @registeredPlain = {}

  registerCommand: (name, opt, func)=>
    return null if not name?
    command = new BotCommand @engine, name, opt, func
    command = new BotCommand @engine, name, {}, opt if typeof opt is 'function'
    @registered[name] = command
    @registeredPlain[name] = command
    @registeredPlain[alias] = command for alias in opt.aliases if opt.aliases?
    command
  
  unregisterCommand: (command)=>
    if typeof command is 'string'
      command = @registered[name]
    return false if not command?
    @registered[command.name] = null
    @registeredPlain[command.name] = null
    @registeredPlain[alias] = null for alias in command.aliases if command.aliases?
    true

  unregisterCommands: (commands)=>
    @unregisterCommand command for command in commands
  
  executeCommand: (msg)=>
    name = msg.content[@prefix.length..].split(' ')[0].toLowerCase()
    args = msg.content[@prefix.length+name.length+1..]
    command = @registeredPlain[name]
    return false if not command?
    if command.djOnly and not @permissions.isDJ msg.author, msg.guild
      msg.reply "You don't have enough permissions to execute that command."
      return false
    if command.adminOnly and not @permissions.isAdmin msg.author, msg.guild
      msg.reply "You don't have enough permissions to execute that command."
      return false
    if command.ownerOnly and not @permissions.isOwner msg.author
      msg.reply "Only the owner has access to that command."
      return false
    if command.argSeparator?
      args = args.split(command.argSeparator)
      args.unshift 'name' if command.includeCommandNameInArgs
    args = [name, args]  if command.includeCommandNameInArgs

    try
      command.exec msg, args
      true
    catch e
      console.error e
      false

module.exports = BotCommandManager
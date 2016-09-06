reload = require('require-reload')(require)
engine = {}

###
Thy Module Base
###
class BotModule
  constructor: ->
    @engine = engine
    { @bot, @permissions } = engine
    @commands = []

  registerCommand: (name, options, func)=>
    try
      @commands.push @engine.commands.registerCommand(name, options, func)
    catch e
      console.error e
  
  shutdown: ()=>
    @beforeUnload() if typeof @beforeUnload is 'function'
    @engine.unregisterCommands @commands

global.BotModule = BotModule

###
Thy Module Manager
###
class BotModuleManager
  constructor: (@engine)->
    engine = @engine
    @modules = {}
    
  load: (modules)=>
    for module in modules
      try
        modClass = reload '../modules/'+module
        @modules[module] = new modClass @engine
        @modules[module].init() if typeof @modules[module].init is 'function'
      catch e
        console.error e
  
  unload: (modules)=>
    for module in modules
      try
        @modules[module].shutdown()
        delete @modules[module]

  reload: (modules)=>
    @unload modules
    @load modules

module.exports = BotModuleManager

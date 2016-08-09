###
Thy Module Manager
###
class BotModuleManager
  constructor: (@engine)->
    @modules = {}
    
  load: (modules)=>
    for module in modules
      try
        modClass = require '../modules/'+module
        @modules[module] = new modClass @engine
  
  unload: (modules)=>
    for module in modules
      try
        @modules[module].shutdown()
        @modules[module] = null

  reload: (modules)=>
    @unload modules
    @load modules

module.exports = BotModuleManager

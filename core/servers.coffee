mkdirp = require 'mkdirp'
AudioPlayer = require './audioPlayer'
AudioQueue = require './audioQueue'

# Additional data about servers
class BotServerManager
  constructor: (@engine)->
    @servers = {}

  initServers: (servers)=>
    @addServer server for server in servers
  
  addServer: (server)=>
    mkdirp "data/servers/#{server.id}/queue"
    @servers[server.id] =
      enabled: true,
      admins: [],
      converting: false
    serv = @servers[server.id]
    # Server Specific Classes
    serv.audioPlayer = new AudioPlayer @engine, server
    serv.queue = new AudioQueue @engine, server
    
  removeServer: (server)=>
    @servers[server.id] = null

module.exports = BotServerManager

###
# Discordie doesn't provide webhook support (yet).
# So here's a temporary core module to make FocaBot support them.
###
r = require('request-promise').defaults {
  baseUrl: 'https://discordapp.com/api/'
  headers: {'Authorization': 'Bot ' + process.env.BOT_TOKEN }
  simple: true
}

# WebHook Class #
class WebHook
  constructor: (@bot, data)->
    {
      @id
      @name
      @avatar
      @token
    } = data
    @guild = @bot.Guilds.get data.guild_id
    @channel = @bot.Channels.get data.channel_id
    @user = @bot.Users.get data.user.id
    @avatarURL = "https://cdn.discordapp.com/avatars/#{@id}/#{@avatar}.jpg"
    @path = "/webhooks/#{@id}/#{@token}"

  remove: ()=> r.del @path

  setName: (name)=>
    r.patch @path, { json: { name } }
    .then ()=> @name = name
  
  exec: (json)=>
    r.post @path, { json }
    # Re-cache if no 
    .catch

  execSlack: (json)=>
    r.post "#{@path}/slack", { json }


# WebHook Collection #
class WebHookCollection
  constructor: (@engine)->
    {@bot} = @engine
    @cache = []
    @bot.Dispatcher.on 'GATEWAY_READY', (e)=> 
      e.socket.socket.on('message', @rawGatewayHandler)

  rawGatewayHandler: (e)=>
    try
      {t,d} = JSON.parse(e);
      if t is 'WEBHOOKS_UPDATE'
        @updateCacheForGuild @bot.Guilds.get(d.guild_id)

  addToCache: (hook)=>
    # First check if not in cache
    cached = @cache.find (h)=> hook.id is h.id
    # Then proceed to store it
    @cache.push hook if not cached
    return hook

  updateCacheForGuild: (guild)=>
    # Clear cache
    @cache = @cache.filter (h)=> h.guild.id isnt guild.id
    # Renew cache
    @getForGuild(guild)

  get: (id)=>
    # Find in cache first
    cached = @cache.find (hook)=> hook.id is id
    return Promise.resolve(cached) if cached.length
    # Get it from the api if not cached
    r.get "/webhooks/#{id}", { json: true }
    .then (body)=>
      Promise.resolve @addToCache(new WebHook(body))

  getForGuild: (guild)=>
    # Find in cache first
    cached = @cache.filter (hook)=> hook.guild.id is guild.id
    return Promise.resolve(cached) if cached.length
    # Get them from the API if not cached
    r.get "/guilds/#{guild.id}/webhooks", { json: true }
    .then (body)=>
      hooks = []
      body.forEach (hook)=>
        hooks.push @addToCache(new WebHook(@bot, hook))
      Promise.resolve hooks

  getForChannel: (channel, create=false)=>
    @getForGuild channel.guild
    .then (hooks)=>
      hook = hooks.find (hook)=> hook.channel.id is channel.id
      if hook?
        Promise.resolve(hook)
      else
        @createForChannel channel, "#{@engine.name} - ##{channel.name}"
      
  createForChannel: (channel, name=@engine.name)=>
    r.post "/channels/#{channel.id}/webhooks", { json: { name } }
    .then (body)=> Promise.resolve @addToCache(new WebHook(body))
    

module.exports = WebHookCollection
  
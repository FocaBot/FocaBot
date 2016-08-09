class ServerAudioPlayer
  constructor: (@engine, @server)->
    {@bot, @permissions} = @engine
    @volume = 0.5

  play: (audioChannel, path, flags)=> new Promise (resolve, reject)=>
    {bot, engine, server} = @
    if @currentStream?
      return reject { message: 'Bot is currently playing another file on the server.' }
    @join audioChannel
    .then (connection)=> connection.playFile path
    .then (@currentStream)=>
      @currentStream.on 'end', =>
        @clean()
      resolve @currentStream
    .catch (error)=>
      reject error
    
  join: (audioChannel)=> new Promise (resolve, reject)=>
    if @voiceConnection?
      if @voiceConnection.voiceChannel.id isnt audioChannel.id
        return reject { message: 'Bot is already in another voice channel' } if @currentStream?
        @clean true
      else
        return resolve @voiceConnection
    @bot.joinVoiceChannel audioChannel
    .then (@voiceConnection)=>
      @voiceConnection.setVolume @volume
      resolve @voiceConnection
    .catch (error)=>
      reject error

  setVolume: (@volume)=>@voiceConnection.setVolume @volume
  stop:   ()=>
    @voiceConnection.stopPlaying()
    @clean()
  pause:  ()=> @voiceConnection.pause()
  resume: ()=> @voiceConnection.resume()

  clean: (disconnect)=>
    @currentStream = null
    if disconnect
      @voiceConnection.destroy()
      @voiceConnection = null

module.exports = ServerAudioPlayer

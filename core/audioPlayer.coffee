util = require 'util' 

class GuildAudioPlayer
  constructor: (@engine, @guild)->
    {@bot, @permissions} = @engine
    @volume = 50

  play: (audioChannel, path, flags)=> new Promise (resolve, reject)=>
    if @currentStream?
      return reject { message: 'Bot is currently playing another file on the server.' }
    
    @join audioChannel
    .then (connection)=>
      connection.createExternalEncoder {
        type: 'ffmpeg'
        source: path
        format: 'pcm'
        frameDuration: 60
        outputArgs: flags
      }
    .then (@currentStream)=>
      @encStream = @currentStream.play()
      @voiceConnection.getEncoder().setVolume @volume
      @currentStream.on 'end', =>
        @clean()
      resolve @currentStream
    .catch (error)=>
      reject error
    
  join: (audioChannel)=> new Promise (resolve, reject)=>
    if @voiceConnection?
      if @voiceConnection.channelId isnt audioChannel.id
        return reject { message: 'Bot is already in another voice channel' } if @currentStream?
        @clean true
      else
        return resolve @voiceConnection
    audioChannel.join()
    .then (voiceConnectionInfo)=>
      { @voiceConnection } = voiceConnectionInfo
      resolve @voiceConnection
    .catch (error)=>
      reject error

  setVolume: (@volume)=> @voiceConnection.getEncoder().setVolume @volume
  stop:   ()=>
    try
      @currentStream.stop()
      # @currentStream.destroy()
    @clean()

  clean: (disconnect)=>
    delete @currentStream
    delete @encStream
    if disconnect
      @voiceConnection.disconnect()
      delete @voiceConnection

module.exports = GuildAudioPlayer

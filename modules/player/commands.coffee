reload = require('require-reload')(require)
youtubedl = require 'youtube-dl'
promisify = require 'es6-promisify'

getInfo = promisify(youtubedl.getInfo)

class AudioModuleCommands
  constructor: (@audioModule)->
    { @q } = @audioModule
    { @permissions } = Core
    { @parseTime } = Core.util
    @m = @audioModule

    # Play
    @m.registerCommand 'play', { argSeparator: '|' }, (msg,args,data)=>
      return msg.reply 'No video specified.' if not args[0].trim() and not msg.attachments[0]
      return msg.reply 'You must be in a voice channel to request songs.' if not msg.member.getVoiceChannel()
      # Use first attachment if present
      if msg.attachments[0] then urlToFind = msg.attachments[0].url
      else urlToFind = args[0]
      try
        # Get info from the URL using ytdl
        info = await getInfo(urlToFind, ['--netrc', '--default-search', 'ytsearch', '-f', 'bestaudio'])
      catch
        # probably not a YT link, try again without flags
        try info = await getInfo(urlToFind, [])
        catch
          msg.reply 'Something went wrong.'
      @audioModule.handleVideoInfo info, msg, args, data

    # Skip
    @m.registerCommand 'skip', (msg, args, d)=>
      queue = await @q.getForGuild msg.guild
      u = msg.member.nick or msg.author.username
      return queue.nextItem() if queue.nowPlaying and not queue.audioPlayer.voiceConnection
      # Some checks
      return if msg.author.bot
      return msg.reply 'You must be in a voice channel.' if not msg.member.getVoiceChannel()
      return msg.reply 'You must be in the same voice channel the bot is in.' if queue.audioPlayer.voiceConnection.channelId isnt msg.member.getVoiceChannel().id
      return msg.reply 'Nothing being played in this server.' if not queue.nowPlaying and not queue.items.length
      # Vote skip
      if not @permissions.isDJ(msg.member) and msg.author.id isnt queue.nowPlaying.requestedBy.id
        return msg.reply "You are not allowed to skip songs." if not data.data.voteSkip
        queue.nowPlaying.voteSkip = [] if not queue.nowPlaying.voteSkip

        return msg.reply 'Did you really try to skip this song **again**?' if msg.author.id in queue.nowPlaying.voteSkip
        # Democracy!
        targetVotes = Math.round(msg.member.getVoiceChannel().members.length * 0.4) # ~40% of channel members
        queue.nowPlaying.voteSkip.push(msg.author.id)
        votes = queue.nowPlaying.voteSkip.length
        msg.channel.sendMessage "**#{u}** voted to skip the current song (#{votes}/#{targetVotes})"

        if votes >= targetVotes
          msg.channel.sendMessage "Skipping current song ~~with the power of democracy~~." # lol
          queue.nextItem()
      else
        msg.channel.sendMessage "**#{u}** skipped the current song."
        queue.nextItem()


    @m.registerCommand 'clear', { djOnly: true }, (msg)=>
      queue = await @q.getForGuild msg.guild
      queue.clearQueue()
      msg.channel.sendMessage 'Queue cleared.'

module.exports = AudioModuleCommands

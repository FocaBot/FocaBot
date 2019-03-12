cheerio = require 'cheerio'
Genius = require('request-promise').defaults {
  baseUrl: 'https://genius.com/'
  simple: true
}

class LyricsModule extends BotModule
  init: ->
    try
      @player = Core.modules.loaded['player']
    catch e
      throw new Error 'This module must be loaded before the player module!!'

    @registerCommand 'lyrics', ({ msg, args, l })=>
      player = await @player.getForGuild(msg.guild)
      song = player.queue.nowPlaying
      return msg.reply l.player.notPlaying unless song? or args
      query = args or song.title
      reply = await msg.channel.send embed: {
        author:
          name: l.gen(l.lyrics.searching, query)
          icon_url: 'https://d.thebitlink.com/wheel.gif'
      }
      try
        { response } = await Genius.get('api/search', json: true, qs: q: query)
        songInfo = (response.hits.find((h)-> h.type is 'song') or {}).result
        return reply.edit embed: { description: l.generic.noResults } unless songInfo
        lyricsHtml = await Genius.get(songInfo.path)
        $ = cheerio.load(lyricsHtml)
        # Parse lyrics
        lyrics = @parseLyrics($('.lyrics').children().toArray())
          .trim().substr(0,1800) # Avoid reaching Discord's character limit
        reply.edit embed: {
          color: 0xFFFF64
          title: l.gen(l.lyrics.title, songInfo.full_title)
          thumbnail: url: songInfo.song_art_image_thumbnail_url
          url: "https://genius.com#{songInfo.path}"
          description: """
          #{lyrics}

          [#{l.lyrics.more}](https://genius.com#{songInfo.path})
          """
        }
      catch e
        Core.log e, 2
        reply.edit embed: {
          color: 0xFF0000
          description: l.generic.error
        }
  
  parseLyrics: (lyricsNodes)->
    lyrics = ''
    for node in lyricsNodes
      prevNode = node.prev or {}
      nextNode = node.next or {}
      if node.type is 'text'
        lyrics += node.data
      else if node.name is 'br' and prevNode.name isnt nextNode.name
        lyrics += '\n'
      else if node.children and node.children.length
        lyrics += @parseLyrics(node.children) # papa bless recursion
    return lyrics

module.exports = LyricsModule

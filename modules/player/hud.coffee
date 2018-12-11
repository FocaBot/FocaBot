{ delay } = Core.util

class PlayerHUD
  constructor: (@audioModule)->
    { @util } = @audioModule

    # Handle events
    @audioModule.registerEvent 'player.start', (player, item)=> try
      return unless item.notify
      item.notify = false
      s = await Core.settings.getForGuild(player.guild)
      l = Core.locales.getLocale(s.locale)
      # Show "Now Playing" when an item starts playing
      m = await item.textChannel.send l.gen(l.player.hud.nowPlaying, item.voiceChannel.name),
                                      embed: await @nowPlayingEmbed(item, l)
      await delay(5000)
      try m.delete() if s.autoDel

    @audioModule.registerEvent 'player.newQueueItem', (player, queue, { item, index })=> try
      s = await Core.settings.getForGuild(player.guild)
      l = Core.locales.getLocale(s.locale)
      # Show "Item Added" when a new item is added
      item.textChannel.send l.player.hud.added,
                            embed: @addItem(item, index + 1, player, l)

  ###
  # Messages
  ###
  nowPlaying: (item, l)->
    """
    #{@generateProgressOuter item}
    #{l.gen(l.player.hud.nowPlaying, item.voiceChannel.name)}
    >`#{item.title}` (#{@util.displayTime item.duration}) #{@util.displayFilters item.filters}
    #{if item.radioStream then '\n\n' + (await @radioInfo(item, l)) + '\n' else ''}
    #{l.gen(l.player.hud.requestedBy, item.requestedBy.displayName)}
    #{@loopModeInd item.queue.loopMode, l}
    """

  radioInfo: (item, l)->
    return '' unless item.radioStream
    meta = await @util.getRadioTrack(item)
    """
    #{l.player.hud.radioStream}

    #{l.gen(l.player.hud.radioTrack, meta.current or '???')}
    #{l.gen(l.player.hud.radioNext, meta.next or '???')}
    """

  swapItems: (user, items, indexes, l)->
    """
    #{l.gen(l.player.hud.swap, user.displayName)}
    ```fix
    * #{indexes[1]+1} -> #{indexes[0]+1}
      #{items[0].title}

    * #{indexes[0]+1} -> #{indexes[1]+1}
      #{items[1].title}
    ```
    """

  moveItem: (user, item, indexes, l)->
    """
    #{l.gen(l.player.hud.move, user.displayName)}
    ```fix
    * #{indexes[0]+1} -> #{indexes[1]+1}
      #{item.title}
    ```
    """

  ###
  # Embeds
  ###
  addItem: (item, pos, player, l)->
    # Calculate estimated time
    estimated = -item.duration + item.time
    if player.queue._d.nowPlaying
      estimated += player.queue.nowPlaying.duration - player.queue.nowPlaying.time
    estimated += el.duration - el.time for el in player.queue.items
    
    reply =
      url: item.sauce
      color: 0xAAFF00
      title: l.generic.sauceBtn
      description: "[#{l.generic.donateBtn}](https://tblnk.me/focabot-donate/)"
      author:
        name: item.title
        icon_url: @util.getIcon item.sauce
      thumbnail:
        url: item.thumbnail
      fields: [
        {
          name: l.player.hud.length
          value: "#{@util.displayTime item.duration}\n "
          inline: true
        }
        { name: l.player.hud.position, value: "##{pos}", inline: true }
      ]
      footer:
        icon_url: item.requestedBy.user.avatarURL
        text: l.gen(l.player.hud.requestedBy, item.requestedBy.displayName)
    if @util.displayFilters(item.filters)
      reply.description += """
      \n**#{l.player.hud.filters}**: #{@util.displayFilters(item.filters)}
      """
    if item.time and item.time > 0
      reply.fields.push {
        name: l.player.hud.startTime
        value: @util.displayTime(item.time)
        inline: true
      }
    if estimated
      reply.fields.push {
        name: l.player.hud.estimated,
        value: @util.displayTime(estimated)
      }
    reply

  removeItem: (item, removedBy, l)->
    reply =
      url: item.sauce
      color: 0xF44277
      title: l.generic.sauceBtn
      description: "[#{l.generic.donateBtn}](https://tblnk.me/focabot-donate/)"
      author:
        name: item.title
        icon_url: @util.getIcon item.sauce
      thumbnail:
        url: item.thumbnail
    if removedBy
      reply.footer =
        icon_url: removedBy.user.avatarURL
        text: l.gen(l.player.hud.removedBy, removedBy.displayName)
    reply

  addPlaylist: (user, playlist, channel, l, s)->
    message = undefined
    sending = false
    lastCount = 0
    updateMessage = (done)=>
      return if sending or (playlist.items.length is lastCount and not done)
      embed = {
        author:
          name: if playlist.partial
            l.player.hud.playlistLoading
          else
            l.player.hud.playlistLoaded
          icon_url: if playlist.partial then 'https://d.thebitlink.com/wheel.gif'
        description: if playlist.partial
          l.gen(l.player.hud.playlistCount, playlist.items.length, "#{s.prefix}cancel")
        else
          l.gen(l.player.hud.playlistFinalCount, playlist.items.length)
        footer:
          icon_url: user.user.avatarURL
          text: l.gen(l.player.hud.requestedBy, user.displayName)
      }
      lastCount = playlist.items.length
      unless message
        sending = channel.send '', { embed }
        message = await sending
        sending = null
      else
        sending = message.edit '', { embed }
        await sending
        sending = null
    updateMessage()
    if playlist.partial
      interval = setInterval(updateMessage, 2500)
      playlist.once 'done', =>
        return if playlist.cancelled
        await sending if sending
        updateMessage(true)
        clearInterval(interval)
      playlist.once 'cancelled', =>
        playlist.cancelled = true
        await sending if sending
        if message then message.edit '', embed: {
          author: name: l.player.hud.playlistCancelled
        }
        clearInterval(interval)

  nowPlayingEmbed: (item, l)->
    r ={
      url: item.sauce
      color: 0xCCAA00
      title: l.generic.sauceBtn
      description: """
      [#{l.generic.donateBtn}](https://tblnk.me/focabot-donate/)
      #{@generateProgressOuter item}\
      #{@loopModeInd item.queue.loopMode, l}
      """
      author:
        name: item.title
        icon_url: @util.getIcon item.sauce
      thumbnail:
        url: item.thumbnail
      footer:
        text: l.gen(l.player.hud.requestedBy, item.requestedBy.displayName)
        icon_url: item.requestedBy.user.avatarURL
      fields: [
        { inline: true, name: l.player.hud.length, value: @util.displayTime item.duration }
      ]
    }
    if @util.displayFilters(item.filters)
      r.fields.push {
        inline: true, name: l.player.hud.filters, value: @util.displayFilters item.filters
      }
    if item.radioStream
      r.description += "\n#{await @radioInfo(item, l)}"
    r

  queue: (q, page=1, l, s)->
    return { description: l.player.hud.queueEmpty } if not q.items.length

    # Calculate total time
    totalTime = 0
    totalTime += el.duration for el in q.items

    itemsPerPage = 10
    pages = Math.ceil(q._d.items.length / itemsPerPage)
    if page > pages
      return { color: 0xFF0000, description: l.gen(l.player.hud.noSuchPage, page) }

    r = {
      color: 0x00AAFF
      title: l.player.hud.upNext
      description: ''
      footer:
        text: l.gen(
          l.player.hud.queueFooter, q._d.items.length, @util.displayTime(totalTime), page, pages
        )
    }

    offset = (page-1) * itemsPerPage
    max = offset + itemsPerPage

    for qI, i in q.items.slice offset, max
      r.description += """
      **#{offset+i+1}.** \
      [#{qI.title.replace(/\]/, '\\]').substr(0, 50)}]\
      (#{qI.sauce.replace(/\)/, '\\)')}) \
      #{@util.displayFilters qI.filters} \
      (#{@util.displayTime qI.duration}) \
      #{l.gen l.player.hud.requestedBy, qI.requestedBy.displayName}\n
      """
    r.description += l.gen(l.player.hud.queueNext, "#{s.prefix}queue #{page+1}") if page < pages
    r

  ###
  # Functions
  ###
  generateProgressOuter: (item)->
    pB = @util.generateProgressBar item.time / item.duration
    iC = '▶'
    iC = '⏸' if item.status is 'paused' or item.status is 'suspended'
    iC = '📡' if not item.duration
    iC = '📻' if item.radioStream
    """
    ```fix
     #{iC}  #{@generateVolumeInd item.volume}  #{pB} #{@util.displayTime(item.time)}
    ```
    """

  generateVolumeInd: (vol)->
    return '🔊' if vol >= 0.6
    return '🔉' if vol >= 0.3
    '🔈'

  loopModeInd: (loopMode, l)->
    return "\n#{l.player.hud.songLoopMode}" if loopMode is 'single'
    return "\n#{l.player.hud.playlistLoopMode}" if loopMode is 'all'
    ''

module.exports = PlayerHUD

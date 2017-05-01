{ delay } = Core.util

class PlayerHUD
  constructor: (@audioModule)->
    { @prefix } = Core.settings
    { @events, @util } = @audioModule
    # Handle events
    @events.on 'start', (player, item)=> try
      # Show "Now Playing" when an item starts playing
      m = await item.textChannel.sendMessage "Now playing in `#{item.voiceChannel.name}`:",
                                              false,
                                              await @nowPlayingEmbed(item)
      await delay(5000)
      m.delete() if player.guildData.data.autoDel
    @events.on 'newQueueItem', (player, queue, { item, index })=> try
      # Show "Item Added" when a new item is added
      item.textChannel.sendMessage 'Added to the queue:',
                                   false,
                                   @addItem(item, index + 1, player)

  ###
  # Messages
  ###
  nowPlaying: (item)=>
    """
    #{@generateProgressOuter item}
    Now playing in **#{item.voiceChannel.name}**:
    >`#{item.title}` (#{@util.displayTime item.duration}) #{@util.displayFilters item.filters}
    #{if item.radioStream then '\n\n' + (await @radioInfo(item)) + '\n' else ''}
    Requested by: **#{item.requestedBy.name}**
    """

  radioInfo: (item)=>
    return '' unless item.radioStream
    meta = await @util.getRadioTrack(item)
    """
    **__Radio Stream__**

    **Track Title:** `#{meta.current or '???'}`
    **Next Track:** `#{meta.next or '???'}`
    """

  swapItems: (user, items, indexes)=>
    """
    #{user.name} swapped some items:
    ```fix
    * #{indexes[1]+1} -> #{indexes[0]+1}
      #{items[0].title}

    * #{indexes[0]+1} -> #{indexes[1]+1}
      #{items[1].title}
    ```
    """

  moveItem: (user, item, indexes)=>
    """
    #{user.name} moved the following item:
    ```fix
    * #{indexes[0]+1} -> #{indexes[1]+1}
      #{item.title}
    ```
    """

  ###
  # Embeds
  ###
  addItem: (item, pos, player)=>
    # Calculate estimated time
    estimated = -item.duration + item.time
    if player.queue._d.nowPlaying
      estimated += player.queue.nowPlaying.duration - player.queue.nowPlaying.time
    estimated += el.duration - el.time for el in player.queue.items
    
    reply =
      url: item.sauce
      color: 0xAAFF00
      title: '[click for sauce]'
      description: '[[donate]](https://tblnk.me/focabot-donate/)'
      author:
        name: item.title
        icon_url: @util.getIcon item.sauce
      thumbnail:
        url: item.thumbnail
      fields: [
        { name: 'Length:', value: "#{@util.displayTime item.duration}\n ", inline: true }
        { name: 'Position in queue:', value: "##{pos}", inline: true }
      ]
      footer:
        icon_url: item.requestedBy.staticAvatarURL
        text: "Requested by #{item.requestedBy.name}"
    if @util.displayFilters(item.filters)
      reply.description += "\n**Filters**: #{@util.displayFilters(item.filters)}"
    if item.time and item.time > 0
      reply.fields.push {
        name: 'Start at:'
        value: @util.displayTime(item.time)
        inline: true
      }
    if estimated
      reply.fields.push {
        name: 'Estimated time before playback:',
        value: @util.displayTime(estimated)
      }
    reply

  removeItem: (item, removedBy)=>
    reply =
      url: item.sauce
      color: 0xF44277
      title: '[click for sauce]'
      description: '[[donate]](https://tblnk.me/focabot-donate/)'
      author:
        name: item.title
        icon_url: @util.getIcon item.sauce
      thumbnail:
        url: item.thumbnail
    if removedBy
      reply.footer =
        icon_url: removedBy.staticAvatarURL
        text: "Removed by #{removedBy.name}"
    reply

  addPlaylist: (user, playlist, channel)=>
    message = undefined
    sending = false
    updateMessage = =>
      return if sending
      embed = {
        author:
          name: if playlist.partial then 'Loading Playlist...' else '✅ Playlist Added!'
          icon_url: if playlist.partial then 'https://d.thebitlink.com/wheel.gif'
        description: """
        **#{playlist.items.length}** items\
        #{if playlist.partial then ' loaded so far..' else ''}.
        """
        footer:
          icon_url: user.staticAvatarURL
          text: "Requested by #{user.name}"
      }
      unless message
        sending = true
        message = await channel.sendMessage '', false, embed
        sending = false
      else
        sending = true
        await message.edit '', embed
        sending = false
    updateMessage()
    if playlist.partial
      interval = setInterval(updateMessage, 2500)
      playlist.on 'done', =>
        sending = false
        updateMessage()
        clearInterval(interval)

  nowPlayingEmbed: (item)=>
    r ={
      url: item.sauce
      color: 0xCCAA00
      title: '[click for sauce]'
      description: """
      [[donate]](https://tblnk.me/focabot-donate/)
      #{@generateProgressOuter item}
      """
      author:
        name: item.title
        icon_url: @util.getIcon item.sauce
      thumbnail:
        url: item.thumbnail
      footer:
        text: "Requested by #{item.requestedBy.name}"
        icon_url: item.requestedBy.staticAvatarURL
      fields: [
        { inline: true, name: 'Length', value: @util.displayTime item.duration }
      ]
    }
    if @util.displayFilters(item.filters)
      r.fields.push { inline: true, name: 'Filters', value: @util.displayFilters item.filters }
    if item.radioStream
      r.description += "\n#{await @radioInfo(item)}"
    r

  queue: (q, page=1)=>
    return { description: 'Nothing currently on queue.' } if not q.items.length

    # Calculate total time
    totalTime = 0
    totalTime += el.duration for el in q.items

    itemsPerPage = 10
    pages = Math.ceil(q._d.items.length / itemsPerPage)
    if page > pages
      return { color: 0xFF0000, description: "Page #{page} does not exist." }

    r = {
      color: 0x00AAFF
      title: 'Up next'
      description: ''
      footer:
        text: """
        #{q._d.items.length} total items (#{@util.displayTime totalTime}). Page #{page}/#{pages}
        """
    }

    r.title += ' [Loop Mode]' if q.player.guildData.data.queueLoop

    offset = (page-1) * itemsPerPage
    max = offset + itemsPerPage

    for qI, i in q.items.slice offset, max
      r.description += """
      **#{offset+i+1}.** [#{qI.title.replace(/\]/, '\\]')}](#{qI.sauce.replace(/\)/, '\\)')}) \
      #{@util.displayFilters qI.filters} \
      (#{@util.displayTime qI.duration}) Requested By #{qI.requestedBy.name}\n
      """
    r.description += "Use #{@prefix}queue #{page+1} to see the next page." if page < pages
    r

  ###
  # Functions
  ###
  generateProgressOuter: (item)=>
    pB = @util.generateProgressBar item.time / item.duration
    iC = '▶'
    iC = '⏸' if item.status is 'paused' or item.status is 'suspended'
    iC = '📻' if item.radioStream
    """
    ```fix
     #{iC}  #{@generateVolumeInd item.volume}  #{pB} #{@util.displayTime(item.time)}
    ```
    """

  generateVolumeInd: (vol)=>
    return '🔊' if vol >= 0.6
    return '🔉' if vol >= 0.3
    '🔈'

module.exports = PlayerHUD

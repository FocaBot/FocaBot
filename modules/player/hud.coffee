moment = require 'moment'
url = require 'url'

class AudioHUD
  constructor: (@audioModule)->
    { @prefix } = Core.settings

  ###
  # Messages
  ###

  nowPlaying: (q, qI)=>
    """
    #{@generateProgressOuter q, qI}
    Now playing in **#{qI.voiceChannel.name}**:
    >`#{qI.title}` (#{@parseTime qI.duration}) #{@parseFilters qI.filters}

    Requested by: **#{@getDisplayName qI.requestedBy}**
    """

  swapItems: (user, items, indexes)=>
    """
    #{@getDisplayName user} swapped some items:
    ```fix
    * #{indexes[1]+1} -> #{indexes[0]+1}
      #{items[0].title}

    * #{indexes[0]+1} -> #{indexes[1]+1}
      #{items[1].title}
    ```
    """

  moveItem: (user, item, indexes)=>
    """
    #{@getDisplayName user} moved the following item:
    ```fix
    * #{indexes[0]+1} -> #{indexes[1]+1}
      #{item.title}
    ```
    """

  ###
  # Embeds
  ###

  addItem: (item, q)=>
    pos = q.items.length
    # Calculate estimated time
    estimated = -item.duration
    # Get current timestamp
    if q.nowPlaying
      try
        tS = q.audioPlayer.timestamp or null
      catch
        tS = q.getTransformedTimestamp(q.nowPlaying, q.nowPlaying.time) or null
      estimated += q.nowPlaying.duration - tS
    estimated += el.duration for el in q.items
    reply =
      url: item.sauce
      color: 0xAAFF00
      title: '[click for sauce]'
      author:
        name: item.title
        icon_url: @getIcon item.sauce
      thumbnail:
        url: item.thumbnail
      fields: [
        { name: 'Length:', value: "#{@parseTime item.duration}\n‌‌ ", inline: true }
        { name: 'Position in queue:', value: "##{pos}", inline: true }
        { name: 'Estimated time before playback:', value: @parseTime(estimated)} if estimated
      ]
      footer:
        icon_url: item.requestedBy.avatarURL
        text: "Requested by #{@getDisplayName item.requestedBy}"
    fstr = @parseFilters(item.filters)
    reply.description = "**Filters**: #{fstr}" if fstr
    reply

  removeItem: (item, removedBy)=>
    reply =
      url: item.sauce
      color: 0xF44277
      title: '[click for sauce]'
      author:
        name: item.title
        icon_url: @getIcon item.sauce
      thumbnail:
        url: item.thumbnail
      fields: [
        { name: 'Length:', value: "#{@parseTime item.duration}\n‌‌ ", inline: true }
      ]
    if removedBy
      reply.footer =
        icon_url: removedBy.avatarURL
        text: "Removed by #{@getDisplayName removedBy}"
    fstr = @parseFilters(item.filters)
    reply.description = "**Filters**: #{fstr}" if fstr
    reply

  addPlaylist: (user, length)=>
    reply =
      color: 0x42A7F4
      description: "Added a playlist of **#{length}** items to the queue!"
      footer:
        icon_url: user.avatarURL
        text: "Requested by #{@getDisplayName user}"

  nowPlayingEmbed: (q, qI)=>
    r ={
      color: 0xCCAA00
      author:
        name: qI.title
        icon_url: @getIcon qI.sauce
      url: qI.sauce
      title: '[click for sauce]'
      description: @generateProgressOuter q, qI
      thumbnail:
        url: qI.thumbnail
      footer:
        text: "Requested by #{@getDisplayName qI.requestedBy}"
        icon_url: qI.requestedBy.avatarURL
      fields: [
        { inline: true, name: 'Length', value: @parseTime qI.duration }

      ]
    }
    if qI.filters and qI.filters.length
      r.fields.push { inline: true, name: 'Filters', value: @parseFilters qI.filters }
    r

  queue: (q, page=1)=>

    return { description: 'Nothing currently on queue.' } if not q.items.length

    # Calculate total time
    totalTime = 0
    totalTime += el.duration for el in q.items

    itemsPerPage = 10
    pages = Math.ceil(q.items.length / itemsPerPage)
    if page > pages
      return { color: 0xFF0000, description: "Page #{page} does not exist." }

    r = {
      color: 0x00AAFF
      title: "Up next"
      description: ''
      footer:
        text: "#{q.items.length} total items (#{@parseTime totalTime}). Page #{page}/#{pages}"
    }

    offset = (page-1) * itemsPerPage
    max = offset + itemsPerPage

    for qI, i in q.items.slice offset, max
      r.description += "**#{offset+i+1}.** [#{qI.title}](#{qI.sauce}) #{@parseFilters qI.filters}" +
                        "(#{@parseTime qI.duration}) Requested By #{@getDisplayName qI.requestedBy}\n"

    r.description += "Use #{@prefix}queue #{page+1} to see the next page." if page < pages
    r

  ###
  # Functions
  ###

  generateProgressBar: (pcnt)=>
    path = '───────────────'
    return path + '─' if pcnt < 0 or isNaN pcnt
    handle = '🔘'
    pos = Math.floor pcnt * path.length
    path.substr(0, pos) + handle + path.substr(pos)

  getDisplayName: (member)=> member.nick or member.username

  generateProgressOuter: (q, itm, b=false)=>
    qI = itm or q.nowPlaying
    vI = '🔊'
    try
      tS = q.audioPlayer.timestamp or null
    catch
      tS = q.getTransformedTimestamp(qI, qI.time) or null
    pB = @generateProgressBar tS / qI.duration
    cT = @parseTime tS
    iC = "▶"
    iC = "⏸" if qI.status is 'paused' or qI.status is 'suspended'
    """
    ```fix
     #{iC}  #{vI}  #{pB} #{cT}
    ```
    """

  parseFilters: (filters)=>
    return "" if not filters
    filterstr = ""
    filterstr += filter.display for filter in filters
    filterstr

  parseTime: (seconds)=>
    return moment.utc(seconds * 1000).format("HH:mm:ss") if isFinite(seconds)
    '∞'

  getIcon: (u)=>
    uri = url.parse(u)
    "#{uri.protocol}//#{uri.host}/favicon.ico"

module.exports = AudioHUD

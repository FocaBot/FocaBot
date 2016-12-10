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

  queue: (q, page=1)=>
    m = ""
    m += @nowPlaying q, q.nowPlaying, false if q.nowPlaying
    page = 1 if isNaN page

    return m + "\nThe queue seems to be empty." if q.items.length <= 0
    itemsPerPage = 10
    ix = (page-1) * itemsPerPage
    max = ix + itemsPerPage
    return m + "\nThere's no such thing as page #{page}" if q.items.length < max-itemsPerPage or page < 1
    pI = if page > 1 then (' - Page ' + page) else ''

    m += "\n**Up next:** (#{q.items.length} items#{pI})\n"

    for qI, i in q.items.slice ix, max
      m += "**#{ix+i+1}.** `#{qI.title}` #{@parseFilters qI.filters}" +
           "(#{@parseTime qI.duration}) Requested By #{@getDisplayName qI.requestedBy}\n"
    
    m += "Use #{@prefix}queue #{page+1} to see the next page." if max < q.items.length
    m

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

  addItem: (item, pos)=>
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

  generateProgressOuter: (q, itm)=>
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

moment = require 'moment'
url = require 'url'

class AudioHUD
  constructor: (@audioModule)->
    { @engine } = @audioModule
    { @permissions, @prefix, @bot } = @engine

  generateProgressBar: (pcnt)=>
    path = '───────────────'
    return path + '─' if pcnt < 0 or isNaN pcnt
    handle = '🔘'
    pos = Math.floor pcnt * path.length
    path.substr(0, pos) + handle + path.substr(pos)

  generateVolumeInd: (vol)=>  
    return '🔊' if vol >= 60
    return '🔉' if vol >= 25
    '🔈'
  
  getDisplayName: (member, mention)=>
    member.mention if mention
    member.nick or member.username

  parseTime: (seconds)=>
    return moment.utc(seconds * 1000).format("HH:mm:ss") if isFinite(seconds)
    '∞'

  generateProgressOuter: (g, itm)=>
    { queue, audioPlayer } = g
    qI = itm or queue.currentItem
    vI = @generateVolumeInd audioPlayer.volume
    tS = if audioPlayer.encStream? then audioPlayer.getTimestamp() else 1
    pB = @generateProgressBar tS / qI.duration
    cT = @parseTime tS
    """
    ```fix
     ▶  #{vI}  #{pB} #{cT}
    ```
    """

  parseFilters: (filters)=>
    filterstr = ""
    filterstr += filter for filter in filters
    filterstr

  nowPlaying: (g, qI, mention)=>
    """
    #{@generateProgressOuter g, qI}
    Now playing in __#{qI.playInChannel.name}__:
    >`#{qI.title}` (#{@parseTime qI.duration}) #{@parseFilters qI.filters}

    Requested by: **#{@getDisplayName qI.requestedBy, mention}** 
    """
  
  queue: (g, page=1)=>
    m = @nowPlaying g, g.queue.currentItem, false
    page = 1 if isNaN page

    return m + "\nThe queue seems to be empty." if g.queue.items.length <= 0
    itemsPerPage = 10
    ix = (page-1) * itemsPerPage
    max = ix + itemsPerPage
    return m + "\nThere's no such thing as page #{page}" if g.queue.items.length < max-itemsPerPage or page < 1
    pI = if page > 1 then (' - Page ' + page) else ''

    m += "\n**Up next:** (#{g.queue.items.length} items#{pI})\n"

    for qI, i in g.queue.items.slice ix, max
      m += "**#{ix+i+1}.** `#{qI.title}` #{@parseFilters qI.filters}" +
           "(#{@parseTime qI.duration}) Requested By #{@getDisplayName qI.requestedBy}\n"
    
    m += "Use #{@prefix}queue #{page+1} to see the next page." if max < g.queue.items.length
    m

  setVolume: (g, member)=>
    """
    #{@generateProgressOuter g}
    #{@getDisplayName member, true} set the volume to #{g.audioPlayer.volume}
    """
  
  getVolume: (g)=>
    """
    #{@generateProgressOuter g}
    Current volume: #{g.audioPlayer.volume}
    """

  addItem: (guild, aby, item, pos)=>
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
        icon_url: aby.avatarURL
        text: "Requested by #{@getDisplayName aby}"
    fstr = @parseFilters(item.filters)
    reply.description = "**Filters**: #{fstr}" if fstr
    reply
  
  removeItem: (guild, aby, item)=>
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
      footer:
        icon_url: aby.avatarURL
        text: "Removed by #{@getDisplayName aby}"
    fstr = @parseFilters(item.filters)
    reply.description = "**Filters**: #{fstr}" if fstr
    reply
  
  getIcon: (u)=>
    uri = url.parse(u)
    "#{uri.protocol}//#{uri.host}/favicon.ico"

  addPlaylist: (aby, length)=>
    reply =
      color: 0x42A7F4
      description: "Added a playlist of **#{length}** items to the queue!"
      footer:
        icon_url: aby.avatarURL
        text: "Requested by #{@getDisplayName aby}"

  swapItems: (guild, aby, items, indexes)=>
    """
    #{@getDisplayName aby} swapped some items:
    ```fix
    * #{indexes[1]+1} -> #{indexes[0]+1}
      #{items[0].title}
    
    * #{indexes[0]+1} -> #{indexes[1]+1}
      #{items[1].title}
    ```
    """

  moveItem: (guild, aby, item, indexes)=>
    """
    #{@getDisplayName aby} moved the following item:
    ```fix
    * #{indexes[0]+1} -> #{indexes[1]+1}
      #{item.title}
    ```
    """

module.exports = AudioHUD

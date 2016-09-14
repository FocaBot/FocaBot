moment = require 'moment'

class AudioHUD
  constructor: (@audioModule)->
    { @getGuildData, @engine } = @audioModule
    { @permissions, @prefix } = @engine

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

  generateProgressOuter: (guild, itm)=>
    { queue, audioPlayer } = @getGuildData(guild)
    qI = itm or queue.currentItem
    vI = @generateVolumeInd audioPlayer.volume
    tS = if audioPlayer.encStream? then audioPlayer.encStream.timestamp else 1
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

  nowPlaying: (guild, qI, mention)=>
    """
    #{@generateProgressOuter guild, qI}
    Now playing in __#{qI.playInChannel.name}__:
    >`#{qI.title}` (#{@parseTime qI.duration}) #{@parseFilters qI.filters}

    Requested by: **#{@getDisplayName qI.requestedBy, mention}** 
    """
  
  queue: (guild, page=1)=>
    g = @getGuildData(guild)
    m = @nowPlaying guild, g.queue.currentItem, false
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

  setVolume: (guild, member)=>
    g = @getGuildData(guild)
    """
    #{@generateProgressOuter guild}
    #{@getDisplayName member, true} set the volume to #{g.audioPlayer.volume}
    """
  
  getVolume: (guild)=>
    g = @getGuildData(guild)
    """
    #{@generateProgressBar guild}
    Current volume: #{g.audioPlayer.volume}
    """

  addItem: (guild, aby, item, pos)=>
    """
    #{@getDisplayName aby} added a new item to the queue:
    ```diff
    + #{item.title}
    ```
    (#{@parseTime item.duration}) #{@parseFilters item.filters} - Position **\##{pos}**
    """

  removeItem: (guild, aby, item)=>
    """
    #{@getDisplayName aby} removed from the queue:
    ```diff
    - #{item.title}
    ```
    """

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

module.exports = AudioHUD

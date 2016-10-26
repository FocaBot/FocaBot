moment = require 'moment'
url = require 'url'

class AudioHUD
  constructor: (@audioModule)->
    { @getGuildData, @engine } = @audioModule
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
    """
    #{@getDisplayName aby} added a new item to the queue:
    ```diff
    + #{item.title}
    ```
    (#{@parseTime item.duration}) #{@parseFilters item.filters} - Position **\##{pos}**
    """

  addItemWebhook: (guild, aby, item, pos)=>
    reply = {
      username: @getDisplayName aby
      icon_url: aby.avatarURL
      text: 'Added a new item to the queue:'
      attachments: [
        {
          color: '#AAFF00'
          title: '[sauce]'
          title_link: item.sauce
          text: """
          **Length**: #{@parseTime item.duration}
          **Position in Queue**: ##{pos}
          """
          author_name: item.title
          author_link: item.sauce
          author_icon: @getIcon item.sauce
          thumb_url: item.thumbnail
        }
      ]
    }
    fstr = @parseFilters(item.filters)
    reply.attachments.push {
      color: '#f442c2'
      text: "**Filters**: #{fstr}"
    } if fstr
    reply.attachments.push {
      color: '#42a7f4',
      footer: "Sent by #{@getDisplayName @bot.User.memberOf(guild)}"
      footer_icon: @bot.User.avatarURL
    }
    return reply

  removeItemWebhook: (guild, aby, item)=>
    reply = {
      username: @getDisplayName aby
      icon_url: aby.avatarURL
      text: 'Removed from the queue:',
      attachments: [
        {
          color: '#F44277'
          title: '[sauce]'
          title_link: item.sauce
          text: "**Length**: #{@parseTime item.duration}"
          author_name: item.title
          title_link: item.sauce
          author_icon: @getIcon item.sauce
          thumb_url: item.thumbnail
        }
        {
          footer: "Sent by #{@getDisplayName @bot.User.memberOf(guild)}"
          footer_icon: @bot.User.avatarURL
        }
      ]
    }
    fstr = @parseFilters(item.filters)
    reply.attachments[0].text += "\n**Filters**: #{fstr}" if fstr
    return reply
  
  getIcon: (u)=>
    uri = url.parse(u)
    "#{uri.protocol}//#{uri.host}/favicon.ico"

  addPlaylist: (aby, length)=>
    "#{@getDisplayName aby} added a playlist of **#{length}** items to the queue!"
  
  addPlaylistWebhook: (aby, length, guild)=> {
      username: @getDisplayName aby
      icon_url: aby.avatarURL
      attachments: [
        {
          color: '#42a7f4'
          text: "Added a playlist of **#{length}** items to the queue!"
          footer: "Sent by #{@getDisplayName @bot.User.memberOf(guild)}"
          footer_icon: @bot.User.avatarURL
        }
      ]
    }

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

  swapItems: (guild, aby, item, indexes)=>
    """
    #{@getDisplayName aby} moved the following item:
    ```fix
    * #{indexes[0]+1} -> #{indexes[1]+1}
      #{item.title}
    ```
    """

module.exports = AudioHUD

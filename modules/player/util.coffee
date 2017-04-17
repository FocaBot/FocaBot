reload = require('require-reload')(require)
moment = require 'moment'
url = require 'url'
{ spawn } = require 'child_process'
{ parseTime } = Core.util
ytdl = require('ytdl-getinfo').getInfo
filterdb = reload './filters'

class PlayerUtil
  constructor: ()->
    { @permissions } = Core

  # Converts an array of filters to an user friendly string
  displayFilters: (filters)=>
    filterstr = ''
    for filter in filters
      filterstr += '\\' + filter.display if filter.display
    filterstr

  # Displays a timestamp (seconds) as a user friendly string
  displayTime: (seconds)=>
    return '--:--:--' unless seconds and seconds > 0
    return moment.utc(seconds * 1000).format('HH:mm:ss') if isFinite(seconds)
    '∞'

  # Gets a favicon from a URL
  getIcon: (u)=>
    uri = url.parse(u)
    "#{uri.protocol}//#{uri.host}/favicon.ico"

  # Gets metadata from a radio stream
  getRadioTrack: (qI)=> new Promise (resolve, reject)=>
    d = ''
    p = spawn('ffprobe', [qI.path, '-show_format', '-v', 'quiet', '-print_format', 'json'])
    p.stdout.on 'data', (data)=> d += data
    p.on 'close', (code)=>
      return resolve { current: '???' } if code
      try
        prop = JSON.parse(d).format
        return resolve {
          current: prop.tags.StreamTitle
          next: prop.tags.StreamNext
        }
      catch
        return resolve { current: '???' }

  # Generates a progress bar (the one used in the "Now Playing" message)
  generateProgressBar: (pcnt)=>
    path = '───────────────'
    return path + '─' if pcnt < 0 or isNaN pcnt
    handle = '🔘'
    pos = Math.floor pcnt * path.length
    path.substr(0, pos) + handle + path.substr(pos)

  # Checks the element duration to avoid long items
  checkLength: (duration, msg, gData)=>
    unless (isFinite(duration) and duration > 0) or @permissions.isDJ(msg.member)
      return 2 # Can't add livestreams
    if (duration > gData.data.maxSongLength and not @permissions.isDJ(msg.member)) or
      (duration > 43200  and not @permissions.isAdmin(msg.member)) or
      (duration > 86400 and not @permissions.isOwner(msg.author))
        return 1 # Video too long
    0

  # Uses FFProbe to get additional metadata of the file/stream
  getAdditionalMetadata: (info)=> new Promise (resolve, reject)=>
    return resolve(info) if (info.duration and isFinite(info.duration)) or info.forEach
    d = ''
    p = spawn('ffprobe', [info.url, '-show_format', '-v', 'quiet', '-print_format', 'json'])
    p.stdout.on 'data', (data)=> d += data
    p.on 'close', (code)=>
      return reject "Process exited with code #{code}" if code
      try
        prop = JSON.parse(d).format
        # Get the duration
        info.duration = prop.duration or NaN
        # Try to use metadata from the ID3 tags as well
        if prop.tags.title
          info.title = ''
          info.title += "#{prop.tags.artist} - " if prop.tags.artist
          info.title += prop.tags.title
        # Is this an internet radio stream?
        if prop.tags.StreamTitle or prop.tags['icy-name']
          info.isRadioStream = true
          info.title = prop.tags['icy-name'] if prop.tags['icy-name']
      resolve(info)

  # Uses youtube-dl to get information of an URL or search term
  getInfo: (query)=> await ytdl(query, [
      '--default-search=ytsearch'
      '--ignore-errors'
      '--force-ipv4',
      '--format=bestaudio/best'
    ])
      

  # Parses a list of filters (| speed=2 distort, etc)
  parseFilters: (arg, member, playing)=>
    return [] if not arg
    filters = []
    for filter in arg.match(/\w+=?\S*/g)
      name = filter.split('=')[0]
      param = filter.split('=')[1]
      Filter = filterdb[name]
      continue if not Filter
      f = new Filter(param, member, playing, filters)
      if playing and f.avoidRuntime
        throw new Error f.display + ' is a static filter and cannot be applied during playback.'
      filters.push(f)
    filters

  # Processes video information (and adds it to the queue)
  processInfo: (info, msg, player, playlist = false, voiceChannel)=>
    return unless info.url
    # Check Length
    duration = parseTime(info.duration)
    if @checkLength(duration, msg, player.guildData)
      msg.reply('The requested video is too long') unless playlist
      return
    # Parse Filters
    try
      filters = @parseFilters(info.filters, msg.member)
    catch errors
      if typeof errors is 'string'
        return if playlist
        return msg.reply 'A filter reported errors:', false, {
          description: errors,
          color: 0xFF0000
        }
    # Add the item to the queue
    player.queue.addItem({
      title: info.title
      requestedBy: msg.member
      voiceChannel: voiceChannel || msg.member.getVoiceChannel()
      textChannel: msg.channel
      path: info.url
      sauce: info.webpage_url
      thumbnail: info.thumbnail
      radioStream: info.isRadioStream or false
      time: info.startAt if isFinite(info.duration) and info.duration > 0
      duration
      filters
    }, playlist, playlist)

  # Checks item count for user
  checkItemCountLimit: (player, member)=>
    return false if @permissions.isDJ(member) or player.guildData.data.maxItems
    itemCount = player.queue._d.items.filter((item)=> item.requestedBy is member.id).length
    return itemCount > player.guildData.data.maxItems

module.exports = new PlayerUtil()

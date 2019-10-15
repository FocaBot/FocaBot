reload = require('require-reload')(require)
moment = require 'moment'
url = require 'url'
{ spawn } = require 'child_process'
{ parseTime } = Core.util
ytdl = require('ytdl-getinfo').getInfo
filterdb = reload './filters'
ffprobe = Core.properties.ffprobeBin
ffmpeg = Core.properties.ffmpegBin

class PlayerUtil
  constructor: ()->
    { @permissions } = Core

  # Converts an array of filters to an user friendly string
  displayFilters: (filters)->
    filterstr = ''
    for filter in filters
      filterstr += '\\' + filter.display if filter.display
    filterstr

  # Displays a timestamp (seconds) as a user friendly string
  displayTime: (seconds)->
    return '--:--:--' unless seconds and seconds > 0
    return moment.utc(seconds * 1000).format('HH:mm:ss') if isFinite(seconds)
    '∞'

  # Gets a favicon from a URL
  getIcon: (u)->
    uri = url.parse(u)
    # return "#{uri.protocol}//#{uri.host}/favicon.ico" # Discord doesn't support .ico anymore
    try
      tld = uri.hostname.match(/[^.]*\.[^.]*$/)[0]
      switch tld
        # coffeelint: disable=max_line_length
        when 'youtube.com', 'youtu.be' then return 'https://www.youtube.com/yts/img/favicon_48-vfl1s0rGh.png'
        when 'soundcloud.com' then return 'https://a-v2.sndcdn.com/assets/images/sc-icons/ios-a62dfc8f.png'
        when 'discordapp.net', 'discordapp.com', 'discord.gg' then return 'https://discordapp.com/assets/2c21aeda16de354ba5334551a883b481.png'
        when 'facebook.com' then return 'https://en.facebookbrand.com/wp-content/uploads/2016/05/FB-fLogo-Blue-broadcast-2.png'
        when 'twitch.tv' then return 'https://cdn1.iconfinder.com/data/icons/micon-social-pack/512/twitch-512.png'
        when 'vimeo.com' then return 'https://upload.wikimedia.org/wikipedia/commons/f/f1/Vimeo_icon_block.png'
        when 'dailymotion.com' then return 'http://press.dailymotion.com/wp-content/uploads/2010/06/LOGO-PRESS-BLOG.png'
        when 'bandcamp.com' then return 'https://bandcamp.com/img/buttons/bandcamp-button-bc-circle-aqua-512.png'
        when 'beatport.com' then return 'https://support.beatport.com/hc/en-us/article_attachments/201330410/Logo_Mark.png'
        # TODO: Add icons for more sites
        # coffeelint: enable=max_line_length

  # Gets metadata from a radio stream
  getRadioTrack: (qI)-> new Promise (resolve, reject)=>
    d = ''
    p = spawn(ffprobe, [qI.path, '-show_format', '-v', 'quiet', '-print_format', 'json'])
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
  generateProgressBar: (pcnt)->
    path = '───────────────'
    return path + '─' if pcnt < 0 or isNaN pcnt
    handle = '🔘'
    pos = Math.floor pcnt * path.length
    path.substr(0, pos) + handle + path.substr(pos)

  # Checks the element duration to avoid long items
  checkLength: (duration, msg, s)->
    unless (isFinite(duration) and duration > 0) or
      s.unrestrictedLivestreams or
      @permissions.isDJ(msg.member)
        return 2 # Can't add livestreams
    if (duration > s.maxSongLength and not @permissions.isDJ(msg.member)) or
      (duration > 43200  and not @permissions.isAdmin(msg.member)) or
      (duration > 86400 and not @permissions.isOwner(msg.member))
        return 1 # Video too long
    0

  # Uses FFProbe to get additional metadata of the file/stream
  getAdditionalMetadata: (info)-> new Promise (resolve, reject)=>
    # Fix for YouTube livestreams
    if info.is_live
      info.duration = NaN
      return resolve(info)
    return resolve(info) if (info.duration and isFinite(info.duration)) or info.forEach
    d = ''
    p = spawn(ffprobe, [info.url, '-show_format', '-v', 'quiet', '-print_format', 'json'])
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
  getInfo: (query)->
    flags = [
      '--youtube-skip-dash-manifest'
      '--default-search=ytsearch'
      '--ignore-errors'
      '--force-ipv4',
      '--format=bestaudio/best'
    ]
    flags.push "--proxy=#{process.env.YTDL_PROXY}" if process.env.YTDL_PROXY
    await ytdl(query, flags)
      

  # Parses a list of filters (| speed=2 distort, etc)
  parseFilters: (arg, member, playing)->
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
  processInfo: (info, msg, player, playlist = false, voiceChannel, play = true)->
    s = await Core.settings.getForGuild(player.guild)
    l = Core.locales.getLocale(s.locale)

    return unless info.url
    # Check Length
    duration = parseTime(info.duration or 0)
    if @checkLength(duration, msg, s)
      msg.reply(l.player.tooLong) unless playlist
      return
    # Parse Filters
    try
      filters = @parseFilters(info.filters, msg.member)
    catch errors
      if typeof errors is 'string'
        return if playlist
        return msg.reply l.player.filterErrors, embed: {
          description: errors
          color: 0xFF0000
        }
    # Add the item to the queue
    player.queue.addItem({
      title: info.title
      requestedBy: msg.member
      voiceChannel: voiceChannel || msg.member.voiceChannel
      textChannel: msg.channel
      path: info.url
      sauce: info.webpage_url
      thumbnail: info.thumbnail
      radioStream: info.isRadioStream or false
      time: info.startAt if isFinite(info.duration) and info.duration > 0
      videoPath: (info.formats.find((f)-> f.width and f.width >= 480) or info).url
      duration
      filters
    }, playlist, not play)

  # Checks item count for user
  checkItemCountLimit: (player, member)->
    return false if @permissions.isDJ(member) or
                    not player.guildData.data.settings or
                    not player.guildData.data.settings.maxItems
    itemCount = player.queue._d.items.filter((item)=> item.requestedBy is member.id).length
    return itemCount > player.guildData.data.settings.maxItems

module.exports = new PlayerUtil()

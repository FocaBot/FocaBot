moment = require 'moment'
url = require 'url'
{ spawn } = require 'child_process'

class PlayerUtil
  constructor: (@playerModule)->

  # Converts an array of filters to an user friendly string
  displayFilters: (filters)=>
    filterstr = ''
    filterstr += '\\' + filter.display for filter in filters
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

module.exports = PlayerUtil

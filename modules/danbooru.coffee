request = require 'request'
danbooru = require('request-promise').defaults {
  baseUrl: 'https://danbooru.donmai.us/'
  auth:
    user: process.env.DANBOORU_LOGIN
    pass: process.env.DANBOORU_API_KEY
  simple: true
}

class DanbooruModule extends BotModule
  init: =>
    @registerCommand 'danbooru', (msg, tags, d)=>
    qs = {
      random: true
      limit: 1
      rating = 's' if not d.data.allowNSFW
      tags
    }
    danbooru.get '/posts.json', { json: true, qs }
    .then (r)=>
      url = "https://danbooru.donmai.us#{r[0].file_url}"
      msg.channel.uploadFile request(url), @getImageName(url)
  
  getFileName: (url)=> url.split('/').reverse()[0]


module.exports = DanbooruModule

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
      tags = 'rating:safe ' + tags if not d.data.allowNSFW
      qs = {
        random: true
        limit: 1
        tags
      }
      danbooru.get '/posts.json', { json: true, qs }
      .then (r)=>
        url = "https://danbooru.donmai.us#{r[0].file_url}"
        msg.channel.uploadFile request(url), @getFileName(url)
      .catch (e)=>
        msg.reply 'Something went wrong.'
  
  getFileName: (url)=> url.split('/').reverse()[0]


module.exports = DanbooruModule

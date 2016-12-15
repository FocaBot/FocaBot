request = require 'request'
{ type } = Core.db

danbooru = require('request-promise').defaults {
  baseUrl: 'https://danbooru.donmai.us/'
  auth:
    user: process.env.DANBOORU_LOGIN
    pass: process.env.DANBOORU_API_KEY
  simple: true
}

safebooru = require('request-promise').defaults {
  baseUrl: 'https://safebooru.donmai.us/'
  auth:
    user: process.env.DANBOORU_LOGIN
    pass: process.env.DANBOORU_API_KEY
  simple: true
}

Waifu = Core.db.createModel 'Waifu', {
  id: type.string()
  user: type.string()
  waifu: type.string()
}

class DanbooruModule extends BotModule
  init: =>
    {@prefix} = @engine

    @registerCommand 'danbooru', {
      allowDM: true
      aliases: ['d']
    }, (msg, tags, d)=>
      if d.danbooruDate
        return msg.reply 'Rate limit excedeed. Wait a few seconds.' if (new Date() - d.danbooruDate) < 3000
      d.danbooruDate = new Date()
      tags = 'rating:safe ' + tags if not d.data.allowNSFW or msg.channel.name.indexOf('nsfw') < 0
      qs = {
        random: true
        tags
      }
      danbooru.get '/posts.json', { json: true, qs }
      .then (r)=>
        if r.length
          url = "https://danbooru.donmai.us#{r[0].file_url}"
          msg.reply '', false, {
            title: '[click for sauce]'
            url: "https://danbooru.donmai.us/posts/#{r[0].id}"
            image: { url }
          }
        else
          msg.reply 'No results.'
      .catch (e)=>
        console.error e
        msg.reply 'Something went wrong.'

    @registerCommand 'safebooru', {
      allowDM: true
      aliases: ['safe']
    }, (msg, tags, d)=>
      if d.danbooruDate
        return msg.reply 'Rate limit excedeed. Wait a few seconds.' if (new Date() - d.danbooruDate) < 3000
      d.danbooruDate = new Date()
      qs = {
        random: true
        tags
      }
      safebooru.get '/posts.json', { json: true, qs }
      .then (r)=>
        if r.length
          url = "https://safebooru.donmai.us#{r[0].file_url}"
          msg.reply '', false, {
            title: '[click for sauce]'
            url: "https://safebooru.donmai.us/posts/#{r[0].id}"
            image: { url }
          }
        else
          msg.reply 'No results.'
      .catch (e)=>
        console.error e
        msg.reply 'Something went wrong.'

    @registerCommand 'setwaifu', { allowDM: true }, (msg, args, d)=>
      return if not d.data.allowWaifus
      waifu = (args.match(/\S+/) or [''])[0]
      return msg.reply "Usage: ```#{@prefix}setWaifu <safebooru_tag>```" if not waifu
      # Do a dummy search
      qs = {
        tags: 'solo ' + waifu
      }
      safebooru.get '/posts.json', { json: true, qs }
      .then (r)=>
        return Promise.reject { msg: 'Invalid safebooru tag.' } if not r.length
        Waifu.filter({ user: msg.author.id }).run()
      .then (results)=>
        return results[0] if results[0]?
        new Waifu { user: msg.author.id }
      .then (w)=>
        w.waifu = waifu
        w.save()
      .then ()=>
        msg.reply 'Success.'
      .catch (e)=>
        console.error e
        return msg.reply e.msg if e.msg
        msg.reply 'Something went wrong.'

    @registerCommand 'waifu', {
      aliases: ['w'],
      allowDM: true
    }, (msg, args, d)=>
      return if not d.data.allowWaifus
      if d.danbooruDate
        return msg.reply 'Rate limit excedeed. Wait a few seconds.' if (new Date() - d.danbooruDate) < 3000
      d.danbooruDate = new Date()
      Waifu.filter({ user: msg.author.id }).run()
      .then (results)=>
        return Promise.reject { msg: "Run the #{@prefix}setWaifu command first." } if not results[0]?
        qs = {
          random: true
          tags: 'solo ' + results[0].waifu
        }
        safebooru.get '/posts.json', { json: true, qs }
      .then (r)=>
        if r.length
          url = "https://safebooru.donmai.us#{r[0].file_url}"
          msg.reply '', false, {
            title: '[click for sauce]'
            url: "https://safebooru.donmai.us/posts/#{r[0].id}"
            image: { url }
          }
        else
          msg.reply 'No results.'
      .catch (e)=>
        console.error e
        return msg.reply e.msg if e.msg
        msg.reply 'Something went wrong.'
  
  getFileName: (url)=> url.split('/').reverse()[0]


module.exports = DanbooruModule

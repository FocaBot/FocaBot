Chance = require 'chance'
Giphy = require('request-promise').defaults {
  baseUrl: 'http://api.giphy.com/v1/gifs/'
  simple: true
}

class GiphyModule extends BotModule
  init: =>
    @chance = new Chance()

    @registerCommand 'giphy', { aliases: ['gif'], allowDM: true }, (msg, q, d)=>
      return unless d.data.allowImages
      try
        { data } = await Giphy.get('search', {
          json: true, qs: { q, api_key: 'dc6zaTOxFJmzC' }
        })
      return msg.reply 'No results' unless data.length
      msg.reply @chance.pickone(data).bitly_url

module.exports = GiphyModule

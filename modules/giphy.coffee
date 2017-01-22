Chance = require 'chance'
Giphy = require('request-promise').defaults {
  baseUrl: 'http://api.giphy.com/v1/gifs/'
  simple: true
}

class GiphyModule extends BotModule {
  init: =>
    @chance = new Chance()

    @registerCommand 'giphy', { aliases: ['gif'], allowDM: true }, (msg, q)=>
      try
        { data } = await Giphy.get('search', { qs: { q, api_key: 'dc6zaTOxFJmzC' } })
      return msg.reply 'No results' if not data.length
      msg.reply @chance.pickone(data).url
}

module.exports = GiphyModule

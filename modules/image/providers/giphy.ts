import { Azarasi } from 'azarasi'
import request from 'request-promise-native'
import { IPictureProvider } from '.'
import { RequestAPI } from 'request'
import { Url } from 'url'
import Chance from 'chance'

export default class Giphy implements IPictureProvider {
  name = 'giphy'
  aliases = ['gif']
  chance = new Chance()

  api : RequestAPI<request.RequestPromise, request.RequestPromiseOptions, { uri: string | Url }>

  constructor (az : Azarasi) {
    this.api = request.defaults({
      baseUrl: 'http://api.giphy.com/v1/',
      simple: true,
      json: true,
      headers: {
        'User-Agent': `${az.properties.name}/${az.properties.version}`,
        Authorization: `Client-ID: ${az.properties.focaBot.apiKeys.imgur}`
      }
    })
  }

  async getRandomImage (query : string, allowNSFW : boolean) {
    const results = await this.api.get('gifs/search', { qs: {
      q: query,
      api_key: 'dc6zaTOxFJmzC' // Public API key for bots.
    }})
    if (!results || !results.data) throw { statusCode: 404, message: 'No results.' }
    const image = await this.chance.pickone(results.data) as any
    return {
      webUrl: image.bitly_url,
      embedUrl: image.images.original.url
    }
  }
}

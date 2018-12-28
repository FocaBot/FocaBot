import { Azarasi } from 'azarasi'
import request from 'request-promise-native'
import { IPictureProvider } from '.'
import { RequestAPI } from 'request'
import { Url } from 'url'
import Chance from 'chance'

export default class Google implements IPictureProvider {
  name = 'google'
  aliases = ['img', 'rimg']
  chance = new Chance()

  api : RequestAPI<request.RequestPromise, request.RequestPromiseOptions, { uri: string | Url }>

  constructor (az : Azarasi) {
    this.api = request.defaults({
      baseUrl: 'https://www.googleapis.com/customsearch/v1/',
      simple: true,
      json: true,
      headers: {
        'User-Agent': `${az.properties.name}/${az.properties.version}`
      },
      qs: {
        searchType: 'image',
        cx: az.properties.focaBot.apiKeys.google.cx,
        key: az.properties.focaBot.apiKeys.google.apiKey
      }
    })
  }

  async getRandomImage (query : string, allowNSFW : boolean) {
    const { items } = await this.api.get('/', { qs: {
      q: query,
      safe: allowNSFW ? 'off': 'high'
    }})
    if (!items || !items.length) throw { statusCode: 404, message: 'No results.' }
    const { image, link } = this.chance.pickone(items)
    return {
      webUrl: image.contextLink,
      embedUrl: link
    }
  }
}

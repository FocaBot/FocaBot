import { Azarasi } from 'azarasi'
import axios, { AxiosInstance } from 'axios'
import { stringify as qs } from 'querystring'
import { IPictureProvider } from '.'
import Chance from 'chance'

export default class Google implements IPictureProvider {
  name = 'google'
  aliases = ['img', 'rimg']
  chance = new Chance()

  api : AxiosInstance
  cx : string
  apiKey : string

  constructor (az : Azarasi) {
    this.api = axios.create({
      baseURL: 'https://www.googleapis.com/customsearch/v1/',
      headers: {
        'User-Agent': `${az.properties.name}/${az.properties.version}`
      }
    })
    this.cx = az.properties.focaBot.apiKeys.google.cx
    this.apiKey = az.properties.focaBot.apiKeys.google.apiKey
  }

  async getRandomImage (query : string, allowNSFW : boolean) {
    const { items } = (await this.api.get(`/?${qs({
      searchType: 'image',
      cx: this.cx,
      key: this.apiKey,
      q: query,
      safe: allowNSFW ? 'off': 'high'
    })}`)).data

    if (!items || !items.length) throw { statusCode: 404, message: 'No results.' }
    const { image, link } = this.chance.pickone(items)
    return {
      webUrl: image.contextLink,
      embedUrl: link
    }
  }
}


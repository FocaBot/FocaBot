import { Azarasi } from 'azarasi'
import axios, { AxiosInstance } from 'axios'
import { stringify as qs } from 'querystring'
import { IPictureProvider } from '.'
import Chance from 'chance'

export default class Giphy implements IPictureProvider {
  name = 'giphy'
  aliases = ['gif']
  chance = new Chance()

  api : AxiosInstance

  constructor (az : Azarasi) {
    this.api = axios.create({
      baseURL: 'http://api.giphy.com/v1/',
      headers: {
        'User-Agent': `${az.properties.name}/${az.properties.version}`
      }
    })
  }

  async getRandomImage (query : string, allowNSFW : boolean) {
    const results = (await this.api.get(`gifs/search?${qs({
      q: query,
      api_key: 'dc6zaTOxFJmzC' // Public API key for bots.
    })}`)).data
    if (!results || !results.data) throw { statusCode: 404, message: 'No results.' }
    const image = await this.chance.pickone(results.data) as any
    return {
      webUrl: image.bitly_url,
      embedUrl: image.images.original.url
    }
  }
}


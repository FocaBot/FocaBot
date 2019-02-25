import { Azarasi } from 'azarasi'
import axios, { AxiosInstance } from 'axios'
import { stringify as qs } from 'querystring'
import { IPictureProvider } from '.'
import Chance from 'chance'

export default class Imgur implements IPictureProvider {
  name = 'imgur'
  chance = new Chance()

  api : AxiosInstance

  constructor (az : Azarasi) {
    this.api = axios.create({
      baseURL: 'https://api.imgur.com/3/',
      headers: {
        'User-Agent': `${az.properties.name}/${az.properties.version}`,
        Authorization: `Client-ID: ${az.properties.focaBot.apiKeys.imgur}`
      }
    })
  }

  async getRandomImage (query : string, allowNSFW : boolean) {
    const results = (await this.api.get(`gallery/search/top/0/?${qs({ q: query })}`)).data
    if (!results || !results.success || !results.data) throw { statusCode: 404, message: 'No results.' }
    const images = (results.data as any[]).filter(i =>
      !i.is_album && // I should probably add support for albums as well...
      !i.is_ad &&
      (allowNSFW || !i.nsfw)
    )
    const image = await this.chance.pickone(images)
    return {
      webUrl: `https://imgur.com/${image.id}`,
      embedUrl: image.link
    }
  }
}


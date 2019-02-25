import { Azarasi } from 'azarasi'
import { URL } from 'url'
import axios, { AxiosInstance } from 'axios'
import { stringify as qs } from 'querystring'
import { IBooruProvider } from '.'

export default class Yandere implements IBooruProvider {
  readonly name : string
  readonly aliases : string[] = []

  api : AxiosInstance

  constructor (az : Azarasi) {
    this.name = 'yandere'
    this.api = axios.create({
      baseURL: 'https://yande.re/',
      headers: {
        'User-Agent': `${az.properties.name}/${az.properties.version}`
      }
    })
  }

  async getRandomPost (tagsStr : string, allowNSFW : boolean) {
    const tags = tagsStr.split(' ')
    tags.push('order:random')
    if (!allowNSFW) tags.push('rating:safe')
    const post = (await this.api.get(`post.json?${qs({
      tags: tags.join(' '),
      limit: 1
    })}`)).data[0]

    const embedUrl = new URL(post.file_url,'https://yande.re/').toString()

    return {
      id: post.id as number,
      webUrl: `https://yande.re/post/${post.id}`,
      embedUrl
    }
  }
}


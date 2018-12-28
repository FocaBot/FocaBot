import { Azarasi } from 'azarasi'
import {Url, URL} from 'url'
import request, { RequestPromiseOptions } from 'request-promise-native'
import { IBooruProvider } from '.'
import { RequestAPI } from 'request'

export default class Yandere implements IBooruProvider {
  readonly name : string
  readonly aliases : string[] = []

  api : RequestAPI<request.RequestPromise, request.RequestPromiseOptions, { uri: string | Url }>

  constructor (az : Azarasi) {
    this.name = 'yandere'
    const apiOptions : RequestPromiseOptions = {
      baseUrl: 'https://yande.re/',
      simple: true,
      json: true,
      headers: {
        'User-Agent': `${az.properties.name}/${az.properties.version}`
      }
    }
    this.api = request.defaults(apiOptions)
  }

  async getRandomPost (tagsStr : string, allowNSFW : boolean) {
    const tags = tagsStr.split(' ')
    tags.push('order:random')
    if (!allowNSFW) tags.push('rating:safe')
    const post = (await this.api.get('post.json', { qs: {
      tags: tags.join(' '),
      limit: 1
    }}))[0]

    const embedUrl = new URL(post.file_url,'https://yande.re/').toString()

    return {
      id: post.id as number,
      webUrl: `https://yande.re/post/${post.id}`,
      embedUrl
    }
  }
}

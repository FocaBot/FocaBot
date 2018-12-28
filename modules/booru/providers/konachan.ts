import { Azarasi } from 'azarasi'
import {Url, URL} from 'url'
import request, { RequestPromiseOptions } from 'request-promise-native'
import { IBooruProvider } from '.'
import { RequestAPI } from 'request'

export default class Konachan implements IBooruProvider {
  readonly name : string
  readonly aliases : string[]

  api : RequestAPI<request.RequestPromise, request.RequestPromiseOptions, { uri: string | Url }>
  safeApi : RequestAPI<request.RequestPromise, request.RequestPromiseOptions, { uri: string | Url }>

  constructor (az : Azarasi, safeMode=false) {
    this.name = safeMode ? 'konachansafe' : 'konachan'
    this.aliases = safeMode ? ['kcsafe', 'konachans', 'kcs'] : ['kc']
    const apiOptions : RequestPromiseOptions = {
      baseUrl: safeMode ? 'https://konachan.net/' : 'https://konachan.com/',
      simple: true,
      json: true,
      headers: {
        'User-Agent': `${az.properties.name}/${az.properties.version}`
      }
    }

    this.api = request.defaults(apiOptions)
    this.safeApi = request.defaults({...apiOptions, baseUrl: 'https://konachan.net/' })
  }

  async getRandomPost (tagsStr : string, allowNSFW : boolean) {
    const tags = tagsStr.split(' ')
    tags.push('order:random')
    const api = allowNSFW ? this.api : this.safeApi
    const post = (await api.get('post.json', { qs: {
      tags: tags.join(' '),
      limit: 1
    }}))[0]

    const embedUrl = new URL(post.file_url,'https://konachan.com/').toString()

    return {
      id: post.id as number,
      webUrl: `https://konachan.com/post/${post.id}`,
      embedUrl
    }
  }
}

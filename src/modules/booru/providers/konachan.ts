import { Azarasi } from 'azarasi'
import { URL } from 'url'
import axios, { AxiosInstance, AxiosRequestConfig } from 'axios'
import { stringify as qs } from 'querystring'
import { IBooruProvider } from '.'

export default class Konachan implements IBooruProvider {
  readonly name : string
  readonly aliases : string[]

  api : AxiosInstance
  safeApi : AxiosInstance

  constructor (az : Azarasi, safeMode=false) {
    this.name = safeMode ? 'konachansafe' : 'konachan'
    this.aliases = safeMode ? ['kcsafe', 'konachans', 'kcs'] : ['kc']
    const apiOptions : AxiosRequestConfig = {
      baseURL: safeMode ? 'https://konachan.net/' : 'https://konachan.com/',
      headers: {
        'User-Agent': `${az.properties.name}/${az.properties.version}`
      }
    }

    this.api = axios.create(apiOptions)
    this.safeApi = axios.create({...apiOptions, baseURL: 'https://konachan.net/' })
  }

  async getRandomPost (tagsStr : string, allowNSFW : boolean) {
    const tags = tagsStr.split(' ')
    tags.push('order:random')
    const api = allowNSFW ? this.api : this.safeApi
    const post = (await api.get(`post.json?${qs({
      tags: tags.join(' '),
      limit: 1
    })}`)).data[0]

    const embedUrl = new URL(post.file_url,'https://konachan.com/').toString()

    return {
      id: post.id as number,
      webUrl: `https://konachan.com/post/${post.id}`,
      embedUrl
    }
  }
}


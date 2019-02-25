import { Azarasi } from 'azarasi'
import { URL } from 'url'
import axios, { AxiosInstance, AxiosRequestConfig } from 'axios'
import { stringify as qs } from 'querystring'
import { IBooruProvider } from '.'

export default class Danbooru implements IBooruProvider {
  readonly name : string
  readonly aliases : string[]

  api : AxiosInstance
  safeApi : AxiosInstance

  constructor (az : Azarasi, safeMode=false) {
    this.name = safeMode ? 'safebooru' : 'danbooru'
    this.aliases = safeMode ? ['safe'] : ['d']
    const apiOptions : AxiosRequestConfig = {
      baseURL: safeMode ? 'https://safebooru.donmai.us/' : 'https://danbooru.donmai.us/',
      headers: {
        'User-Agent': `${az.properties.name}/${az.properties.version}`
      }
    }
    // Authentication
    if (az.properties.focaBot.apiKeys && az.properties.focaBot.apiKeys.danbooru) {
      apiOptions.auth = {
        username: az.properties.focaBot.apiKeys.danbooru.username,
        password: az.properties.focaBot.apiKeys.danbooru.apiKey
      }
    }

    this.api = axios.create(apiOptions)
    this.safeApi = axios.create({...apiOptions, baseURL: 'https://safebooru.donmai.us/' })
  }

  async getRandomPost (tags : string, allowNSFW : boolean) {
    const api = allowNSFW ? this.api : this.safeApi
    const { data } = await api.get(`posts/random.json?${qs({ tags })}`)

    const embedUrl = new URL(
      // For some reason, some posts have double slashes (//) in the file URL.
      // Discord doesn't like this so we have to filter them
      data.file_url.toString().replace('//data', '/data'),
      'https://danbooru.donmai.us/'
    ).toString()

    return {
      id: data.id as number,
      webUrl: `https://danbooru.donmai.us/posts/${data.id}`,
      embedUrl
    }
  }
}


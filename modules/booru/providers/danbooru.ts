import { Azarasi } from 'azarasi'
import {Url, URL} from 'url'
import request, { RequestPromiseOptions } from 'request-promise-native'
import { IBooruProvider } from '.'
import { RequestAPI } from 'request'

export default class Danbooru implements IBooruProvider {
  readonly name : string
  readonly aliases : string[]

  api : RequestAPI<request.RequestPromise, request.RequestPromiseOptions, { uri: string | Url }>
  safeApi : RequestAPI<request.RequestPromise, request.RequestPromiseOptions, { uri: string | Url }>

  constructor (az : Azarasi, safeMode=false) {
    this.name = safeMode ? 'safebooru' : 'danbooru'
    this.aliases = safeMode ? ['safe'] : ['d']
    const apiOptions : RequestPromiseOptions = {
      baseUrl: safeMode ? 'https://safebooru.donmai.us/' : 'https://danbooru.donmai.us/',
      simple: true,
      json: true,
      headers: {
        'User-Agent': `${az.properties.name}/${az.properties.version}`
      }
    }
    // Authentication
    if (az.properties.focaBot.apiKeys && az.properties.focaBot.apiKeys.danbooru) {
      apiOptions.auth = {
        user: az.properties.focaBot.apiKeys.danbooru.username,
        pass: az.properties.focaBot.apiKeys.danbooru.apiKey
      }
    }

    this.api = request.defaults(apiOptions)
    this.safeApi = request.defaults({...apiOptions, baseUrl: 'https://safebooru.donmai.us/' })
  }

  async getRandomPost (tags : string, allowNSFW : boolean) {
    const api = allowNSFW ? this.api : this.safeApi
    const post = await api.get('posts/random.json', { qs: { tags } })

    const embedUrl = new URL(
      // For some reason, some posts have double slashes (//) in the file URL.
      // Discord doesn't like this so we have to filter them
      post.file_url.toString().replace('//data', '/data'),
      'https://danbooru.donmai.us/'
    ).toString()

    return {
      id: post.id as number,
      webUrl: `https://danbooru.donmai.us/posts/${post.id}`,
      embedUrl
    }
  }
}

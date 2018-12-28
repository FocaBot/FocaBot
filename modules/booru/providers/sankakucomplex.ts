import { Azarasi } from 'azarasi'
import {Url, URL} from 'url'
import request, { RequestPromiseOptions } from 'request-promise-native'
import { IBooruProvider } from '.'
import { RequestAPI } from 'request'

export default class SankakuComplex implements IBooruProvider {
  readonly name = 'sankakucomplex'
  readonly aliases = ['sankaku', 'sc']

  api : RequestAPI<request.RequestPromise, request.RequestPromiseOptions, { uri: string | Url }>

  constructor (az : Azarasi) {
    this.api = request.defaults({
      baseUrl: 'https://capi-beta.sankakucomplex.com/',
      simple: true,
      json: true,
      headers: {
        'User-Agent': `${az.properties.name}/${az.properties.version}`
      }
    })
  }

  async getRandomPost (tagsStr : string, allowNSFW : boolean) {
    const tags = tagsStr.split(' ')
    tags.push('order:random')
    if (!allowNSFW) tags.push('rating:safe')

    const post = (await this.api.get('post/index.json', { qs: {
      tags: tags.join(' '),
      limit: 1
    }}))[0]

    return {
      id: post.id as number,
      webUrl: `https://chan.sankakucomplex.com/post/show/${post.id}`,
      embedUrl: new URL(post.file_url, 'https://chan.sankakucomplex.com/').toString()
    }
  }
}

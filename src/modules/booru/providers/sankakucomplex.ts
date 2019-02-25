import { Azarasi } from 'azarasi'
import { URL } from 'url'
import axios, { AxiosInstance } from 'axios'
import { stringify as qs } from 'querystring'
import { IBooruProvider } from '.'

export default class SankakuComplex implements IBooruProvider {
  readonly name = 'sankakucomplex'
  readonly aliases = ['sankaku', 'sc']

  api : AxiosInstance

  constructor (az : Azarasi) {
    this.api = axios.create({
      baseURL: 'https://capi-beta.sankakucomplex.com/',
      headers: {
        'User-Agent': `${az.properties.name}/${az.properties.version}`
      }
    })
  }

  async getRandomPost (tagsStr : string, allowNSFW : boolean) {
    const tags = tagsStr.split(' ')
    tags.push('order:random')
    if (!allowNSFW) tags.push('rating:safe')

    const post = (await this.api.get(`post/index.json?${qs({
      tags: tags.join(' '),
      limit: 1
    })}`)).data[0]

    return {
      id: post.id as number,
      webUrl: `https://chan.sankakucomplex.com/post/show/${post.id}`,
      embedUrl: new URL(post.file_url, 'https://chan.sankakucomplex.com/').toString()
    }
  }
}


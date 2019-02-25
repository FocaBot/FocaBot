export interface IBooruProvider {
  /** Command name. MUST be lowercase */
  name : string
  /** Command aliases */
  aliases? : string[]
  /** Get random post from provider with matching tags */
  getRandomPost : (tags : string, allowNSFW : boolean) => Promise<IPost>
}

export interface IPost {
  id : number
  webUrl : string
  embedUrl : string
}

export { default as Danbooru } from './danbooru'
export { default as Konachan } from './konachan'
export { default as SankakuComplex } from './sankakucomplex'
export { default as Yandere } from './yandere'


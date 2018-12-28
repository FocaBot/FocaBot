// inb4 this is a copy paste from the 'booru' module (yes, it is)
// Actually, i think i could merge both modules but for now i'll leave them as they are.
import { Azarasi } from 'azarasi'

export interface IPictureProvider {
  /** Command name. MUST be lowercase */
  name : string
  /** Command aliases */
  aliases? : string[]
  /** Perform a search with provider and return a random result. */
  getRandomImage : (query : string, allowNSFW : boolean) => Promise<IPictureMetadata>
}

export interface IPictureMetadata {
  webUrl : string
  embedUrl : string
}

export { default as Giphy } from './giphy'
export { default as Google } from './google'
export { default as Imgur } from './imgur'


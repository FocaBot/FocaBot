/**
 * FocaBot extended typings for Azarasi
 */
import { BotProperties } from 'azarasi/lib'
import { FocaBotConfig } from './focabot-config'

declare module 'azarasi/lib' {
  /**
   * FocaBot Properties (config file)
   */
  interface BotProperties {
    /** Bot Name */
    name : string
    /** Bot Version */
    version : string
    /** Version name */
    versionName : string
    /** FocaBot configuration */
    focaBot : FocaBotConfig
  }
}


/**
 * FocaBot Module Settings TypeScript Definition
 */
import { Settings } from 'azarasi/lib/settings'

declare module 'azarasi/lib/settings' {
  interface Settings {
    raffleMention: boolean
  }
}

import { Locale } from 'azarasi'

export default class PlayerError extends Error {
  constructor (public code = PlayerErrorCode.Unknown, message ?: string) {
    super(message)
  }

  getLocalizedMessage (locale : Locale, cmdPrefix : string) {
    switch (this.code) {
      case PlayerErrorCode.InvalidItem:
      case PlayerErrorCode.InvalidIndex:
        return locale.generic.invalidArgs
      case PlayerErrorCode.QueueFrozen:
        return locale.player.queueFrozen
      default:
        return this.message || locale.generic.error
    }
  }
}

export enum PlayerErrorCode {
  Unknown,
  InvalidIndex,
  InvalidItem,
  QueueFrozen
}

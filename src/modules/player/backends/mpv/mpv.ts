import { PlaybackStatus, PlayerBackend, RuntimeQueueItem, UpdateType } from '../../interfaces'
import PlayerQueue from '../../runtime/PlayerQueue'
import { EventEmitter } from 'events'
import { Azarasi } from 'azarasi'
import { StreamDispatcher, VoiceConnection } from 'discord.js'
import MPVProcess from './process'

export default class MPVBackend extends EventEmitter implements PlayerBackend {
  connection ?: VoiceConnection
  stream ?: StreamDispatcher
  process ?: MPVProcess
  allowScreenshots = true

  constructor (private az : Azarasi, public queue : PlayerQueue) {
    super()
  }

  get currentItem () {
    return this.queue.nowPlaying
  }

  get mpvBinary () {
    return this.az.properties.focaBot.player.mpv.bin || 'mpv'
  }

  // TODO: Filter transforms
  get duration () {
    if (!this.currentItem || !this.currentItem.duration) return
    return this.currentItem.duration
  }

  // TODO: Filter transforms
  get time () {
    if (!this.currentItem || !this.currentItem.duration) return 0
    if (!this.stream || this.stream.destroyed) return this.currentItem.offset || 0
    return (this.currentItem.offset || 0) + (this.stream.time / 1000)
  }

  async connect () {
    if (!this.currentItem) return
    this.connection = await this.currentItem.voiceChannel.join()
    return this.connection
  }

  async start () {
    if (!this.currentItem || (this.stream && !this.stream.destroyed)) return
    const connection = await this.connect()

    // Kill previous process if present
    if (this.process && !this.process.killed) this.process.kill()

    // Launch mpv process
    this.process = new MPVProcess(this.mpvBinary, this.getFlags(this.currentItem))
    await this.process.start()

    // Setup error logging
    this.process.on('error', e => this.az.logError(e))
    this.process.stderr!.on('data', d => this.az.logDebug(d.toString()))
    this.process.on('_debug', (...e) => this.az.logDebug(...e))

    // Begin stream
    this.stream = connection!.playOpusStream(this.process.stdout!)

    // Update state
    this.queue.update(0, { status: PlaybackStatus.Playing }, UpdateType.Discrete)
    this.emit('itemStart', this.currentItem)

    this.stream.on('end', () => {
      this.az.logDebug('Stream ended i guess 🤔')
      // TODO: handle end
    })
  }

  pause () {

  }

  suspend () {

  }

  resume () {

  }

  stop () {

  }

  disconnect () {

  }

  async grabScreenshot () : Promise<Buffer> {
    return Buffer.concat([])
  }

  async fetchMetadata (item: RuntimeQueueItem): Promise<any> {
    return {}
  }

  seek (time: number) {

  }

  setVolume (volume: number) {

  }

  getFlags (item : RuntimeQueueItem) {
    const flags : string[] = [
      '--idle',
      '--no-terminal', // No terminal output
      '--demuxer-lavf-analyzeduration', '0', // Don't analyze duration (avoids delays)
    ]
    // Input stream
    flags.push(
      // item.path,
      '--no-video' // Absolutely no video encoding
    )
    // TODO: Filters
    // TODO: Filter output flags
    // Output
    flags.push(
      '--o=-', // Use stdout
      '--of=data', // Raw output, no container
      '--oac=libopus', // Use opus codec
      '--oacopts=b=64000,vbr=0,ar=48000,ac=2', // 64k bitrate, no VBR, 48kHz sampling rate, 2 channels
    )
    return flags
  }
}

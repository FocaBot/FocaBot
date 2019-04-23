import { PlaybackStatus, PlayerBackend, RuntimeQueueItem, UpdateType } from '../interfaces'
import PlayerQueue from '../runtime/PlayerQueue'
import { EventEmitter } from 'events'
import { Azarasi } from 'azarasi'
import { StreamDispatcher, VoiceConnection } from 'discord.js'
import { ChildProcess, spawn } from 'child_process'

export default class FFMPEGBackend extends EventEmitter implements PlayerBackend {
  connection ?: VoiceConnection
  stream ?: StreamDispatcher
  process ?: ChildProcess

  constructor (private az : Azarasi, public queue : PlayerQueue) {
    super()
  }

  get currentItem () {
    return this.queue.nowPlaying
  }

  get ffmpegBinary () {
    return this.az.properties.focaBot.player.ffmpeg.bin || 'ffmpeg'
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
    // Launch FFMPEG process
    this.process = spawn(this.ffmpegBinary, this.getFlags(this.currentItem))
    // Setup error logging
    this.process.on('error', e => this.az.logError(e))
    this.process.stderr.on('data', d => this.az.logDebug(d))
    // Begin stream
    this.stream = connection!.playOpusStream(this.process.stdout)
    // Update state
    this.queue.update(0, { status: PlaybackStatus.Playing }, UpdateType.Discrete)
    this.emit('itemStart', this.currentItem)

    this.stream.on('end', () => {
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
      '-hide_banner',
      '-analyzeduration', '0',
      '-loglevel', this.az.properties.debug ? 'warning' : '0'
    ]
    // Input flags
    // HTTP(s) auto reconnect for unstable connections
    if (item.path.indexOf('http') === 0) {
      flags.push(
        '-reconnect', '1',
        '-reconnect_at_eof', '1',
        '-reconnect_delay_max', '2'
      )
    }
    // Start time
    flags.push('-ss', (item.offset || 0).toString())
    // TODO: Filter input flags
    // Input stream
    flags.push(
      '-i', item.path,
      '-vn' // Absolutely no video encoding
    )
    // TODO: Filters
    // TODO: Filter output flags
    flags.push(
      '-f', 'data', // Raw output, no container
      '-map', '0:a', // Map audio to first stream
      '-ar', '48k', // 48k sampling frequency
      '-ac', '2', // 2 audio channels (stereo)
      '-acodec', 'libopus', // Use opus codec
      '-sample_fmt', 's16', // 16bits signed
      '-vbr', 'off', // Disable variable bitrate
      '-b:a', '64k', // 64k fixed bitrate
      'pipe:1' // Output to stdout
    )
    return flags
  }
}

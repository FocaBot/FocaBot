import { EventEmitter } from 'events'
import { ChildProcess, spawn } from 'child_process'
import net, { Socket } from 'net'
import Stream from 'stream'
import path from 'path'
import fs from 'mz/fs'
import os from 'os'
import Chance from 'chance'

export default class MPVProcess extends EventEmitter {
  childProcess ?: ChildProcess
  ipcSocket ?: Socket
  stdout ?: Stream.Readable
  stderr ?: Stream.Readable
  debug = false

  tempPath !: string
  ipcPath !: string
  ssPath !: string

  constructor (public binaryLocation : string, public args : string[]) {
    super()
  }

  async start () {
    this.tempPath = await fs.mkdtemp(path.join(os.tmpdir(), 'focabot-'), { encoding: 'utf8' })

    this.ipcPath = path.join(
      os.platform() === 'win32' ? '\\\\.\\pipe' : this.tempPath,
      `focabot-ipc-${new Chance().guid()}`
    )
    this.ssPath = path.join(this.tempPath, 'ss')

    return new Promise((resolve, reject) => {
      console.log(this.binaryLocation, `--input-ipc-server=${this.ipcPath}`, ...this.args)
      this.childProcess = spawn(this.binaryLocation, [
        `--input-ipc-server=${this.ipcPath}`,
        ...this.args
      ])

      this.childProcess.on('error', (...e) => {
        this.emit('error', ...e)
        reject(e[0])
      })

      this.childProcess.on('close', (...e) => this.emit('close', ...e))
      this.stdout = this.childProcess.stdout
      this.stderr = this.childProcess.stderr

      setTimeout(() => {
        if (this.childProcess!.killed) return
        this.ipcSocket = net.connect(this.ipcPath, () => {
          this.emit('ready', resolve)
          resolve()
        })
        this.ipcSocket.on('error', e => reject(e))
        this.ipcSocket.on('data', s => s
          .toString()
          .split('\n')
          .filter(d => d.trim())
          .forEach(d => this.processIPCEvent(d))
        )
      }, 1000)
    })
  }

  /**
   * Closes the IPC pipe and kills the main process.
   */
  kill () {
    if (this.ipcSocket) this.ipcSocket.end()
    if (this.childProcess) this.childProcess.kill()
  }

  get killed () {
    return !this.childProcess || this.childProcess.killed
  }

  /**
   * Processes events sent from mpv
   * @param d - Raw IPC message
   */
  processIPCEvent (d : string) {
    const data = JSON.parse(d)
    if (data.event) {
      this.emit('_debug', d)
      this.emit('mpv-event', data)
    } else if (data.error) {
      this.emit('mpv-ipc-response', data)
    }
  }

  /**
   * Send an IPC command to mpv.
   * @param command - Command to send
   * @returns Response from mpv
   */
  sendIPC (...command : string[]) : Promise<unknown> {
    if (!this.ipcSocket) throw new Error('IPC Socket not ready!')
    const message = JSON.stringify({ command }) + os.EOL
    return new Promise((resolve, reject) => {
      this.once('mpv-ipc-response', data => {
        const res = data as MPVIPCResponse
        this.emit('_debug', { command }, '->', res.data)
        if (res.error !== 'success') return reject(new Error(res.error))
        resolve(res.data)
      })
      if (this.ipcSocket) {
        this.ipcSocket.write(Buffer.from(message, 'utf8'))
      }
    })
  }
}

export interface MPVIPCResponse {
  error ?: string
  event ?: string
  data : unknown
}

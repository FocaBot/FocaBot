import { Command } from 'commander'
import { configPath, loadConfig, saveConfig } from '../common'
import { FocaBotConfig } from '../../focabot-config'

export async function ReconfigureAction (ctx : ReconfigureActionContext) : Promise<FocaBotConfig> {
  const config = await loadConfig(ctx.config, true)
  // TODO: Interactive configuration wizard
  await saveConfig(config, ctx.config)
  console.log(`An empty configuration file was created at ${ctx.config || configPath}. Please edit it and restart the bot.`)

  await waitForKeypress()
  process.exit()

  return config
}

function waitForKeypress () {
  return new Promise(resolve => {
    if (process.stdin.isTTY) {
      console.log('\nPress any key to close this message.')
      process.stdin.setRawMode!(true)
      process.stdin.resume()
      process.stdin.on('data', () => {
        resolve()
      })
    } else {
      resolve()
    }
  })
}

interface ReconfigureActionContext extends Command {
  config ?: string
  advanced ?: boolean
}

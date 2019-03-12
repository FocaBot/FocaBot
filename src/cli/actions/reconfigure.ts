import { Command } from 'commander'
import { configPath, loadConfig, saveConfig } from '../common'
import { FocaBotConfig } from '../../focabot-config'

export async function ReconfigureAction (ctx : ReconfigureActionContext) : Promise<FocaBotConfig> {
  const config = await loadConfig(ctx.config, true)
  // TODO: Interactive configuration wizard
  await saveConfig(config, ctx.config)
  console.log(`An empty configuration file was created at ${ctx.config || configPath}. Please edit it.`)
  process.exit()
  return config
}

interface ReconfigureActionContext extends Command {
  config ?: string
  advanced ?: boolean
}

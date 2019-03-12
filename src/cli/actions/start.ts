import { Command } from 'commander'
import { ReconfigureAction } from './reconfigure'
import { FocaBotConfig } from '../../focabot-config'
import { loadConfig, printHeader, configPath } from '../common'
import { ShardingManager } from 'discord.js'
import path from "path"

export async function StartAction (ctx : StartActionContext) {
  printHeader()
  // Load config file
  let config : FocaBotConfig
  try {
    config = await loadConfig(ctx.config)
  } catch (e) {
    console.error(e.message)
    console.log('Performing initial setup...')
    config = await ReconfigureAction(ctx)
  }
  // Setup environment
  process.env.FOCABOT_CONFIG = ctx.cfg || configPath
  process.env.FOCABOT_DEBUG = ctx.debug ? '1' : '0'
  // Launch the bot
  if (ctx.sharding) {
    return LaunchShards(config)
  } else {
    console.log('Launching in single-process mode...')
    return LaunchSingle()
  }
}

async function LaunchShards (config : FocaBotConfig) {
  const shardManager = new ShardingManager(path.join(__dirname, '..', 'shard.js'), {
    token: config.bot.token
  })
  try {
    await shardManager.spawn()
  } catch (e) {
    console.error('Sharding unavailable, falling back to single-process mode.')
    LaunchSingle()
  }
}

function LaunchSingle () {
  require('../shard')
}

interface StartActionContext extends Command {
  config ?: string
  debug ?: boolean
  sharding ?: boolean
}

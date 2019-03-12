import { FocaBotConfig } from './focabot-config'
import printHeader from './header'
import yaml from 'js-yaml'
import path from 'path'
import fs from 'fs'
import { ShardingManager } from 'discord.js'

// Print header
printHeader()

// Load Config
const configFile = path.join(__dirname, '..', 'focabot.yml')
const config = yaml.safeLoad(fs.readFileSync(configFile, 'utf-8')) as FocaBotConfig

// Start shard manager
let shardManager : ShardingManager

if (process.env.TS_NODE_FILES) {
  shardManager = new ShardingManager(path.join(__dirname, 'shard.ts'), {
    token: config.bot.token,
    shardArgs: ['-r', 'ts-node/register']
  })
} else {
  shardManager = new ShardingManager(path.join(__dirname, 'shard.js'), {
    token: config.bot.token
  })
}

if (process.env.FOCABOT_NOSHARDING) {
  console.log('Launching in single-process mode.')
  require('./shard')
} else {
  shardManager.spawn()
  .catch(() => {
    console.error('Sharding unavailable, falling back to single-process mode.')
    require('./shard')
  })
}


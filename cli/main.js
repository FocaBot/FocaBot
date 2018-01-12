#!/usr/bin/env node
require('coffeescript/register')
const fs = require('fs')
const mkdirp = require('mkdirp')
const path = require('path')
const Discord = require('discord.js')
let config

const home = process.env[(process.platform === 'win32') ? 'USERPROFILE' : 'HOME']
const dataPath = path.join(home, '.focaBot')
const configFile = path.join(dataPath, 'settings.json')

mkdirp.sync(dataPath)

console.log(`
       .-.
      :   ;
       "."               FocaBot v1.0.0-alpha (Elegant Erizo)
       / \\               by > thebit.link
      /  |
    .'    \\
   /.'   \`.\\             Documentation: https://next.focabot.xyz/
   ' \\    \`\`.            Support Server: https://discord.gg/V5drVUS
     _\`.____ \`-._        GitHub: https://www.github.com/FocaBot/
    /^^^^^^^^\`.\\^\\
   /           \`  \\
""""""""""""""""""""""""
`)

async function checkArgv () {
  // Parse argv
  switch (process.argv[2]) {
    case undefined:
    case '':
    case 'start':
      break
    case 'reconfigure':
      config = await require('./reconfigure')()
      fs.writeFileSync(configFile, JSON.stringify(config), 'utf-8')
      process.exit()
      break
    case 'configure':
    case 'config':
      if (fs.existsSync(configFile)) {
        config = JSON.parse(fs.readFileSync(configFile, 'utf-8'))
        await require('./config')(config, configFile)
      } else {
        console.error('No configuration file found. Run "focabot reconfigure" to create one.')
      }
      process.exit()
      break
    case 'help':
    case '-h':
    case '--help':
    case '-?':
      console.log(`
Usage: focabot <command>

Available Commands:

  help - Displays this help
  start - Starts FocaBot
  config - Changes configuration parameters
  reconfigure - Runs the initial setup
      `)
      process.exit()
  }
}

// Check if there's a configuration file
fs.exists(configFile, async exists => {
  await checkArgv()
  if (!exists) {
    // Run the first time configuration
    config = await require('./reconfigure')()
    fs.writeFileSync(configFile, JSON.stringify(config), 'utf-8')
  } else {
    // Load configuration
    config = JSON.parse(fs.readFileSync(configFile, 'utf-8'))
  }

  const ShardManager = new Discord.ShardingManager(path.join(__dirname, 'shard.js'), {
    token: config.token
  })

  ShardManager.spawn()
})

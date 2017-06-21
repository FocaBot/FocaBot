#!/usr/bin/env node
require('coffeescript/register')
const fs = require('fs')
const mkdirp = require('mkdirp')
const path = require('path')
let config

const home = process.env[(process.platform === 'win32') ? 'USERPROFILE' : 'HOME']
const dataPath = path.join(home, '.focaBot')
const configFile = path.join(dataPath, 'settings.db')
const Azarasi = require('azarasi')
const ffmpeg = require('ffmpeg-downloader')

mkdirp.sync(dataPath)

console.log('FocaBot Bootstrapper v0.1.0')
console.log('by>thebit.link - https://www.focabot.xyz/')

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
  // Instantiate the bot
  const focaBot = new Azarasi({
    name: 'FocaBot',
    version: '1.0.0 (Elegant Erizo)',
    token: config.token,
    prefix: config.prefix,
    adminRoles: [ config.adminRole ],
    djRoles: [ config.djRole ],
    modulePath: path.join(__dirname, '../modules/'),
    localePath: path.join(__dirname, '../locales/'),
    locale: config.defaultLocale,
    ffmpegBin: ffmpeg.path
  })

  // Parameters
  focaBot.settings.register('autoDel', { type: Boolean, def: true })
  // Modules
  focaBot.modules.load(['util', 'admin'])
  focaBot.modules.load(config.modules)
  // Translations
  const translations = ['ar_SA', 'en_US', 'es_ES', 'fr_FR']
  translations.forEach(t => focaBot.locales.loadLocale(t))
  // Invite Link
  focaBot.bot.on('ready', async () => {
    try {
      const app = await focaBot.bot.fetchApplication()
      focaBot.log('To add the bot to your server, use this link: ')
      focaBot.properties.owner = [ app.owner.id ]
      focaBot.permissions.owner = focaBot.properties.owner
      focaBot.log(`https://discordapp.com/oauth2/authorize?client_id=${app.id}&scope=bot&permissions=57408`)
    } catch (e) {}
    focaBot.log('Official Support Server:')
    focaBot.log('https://discord.gg/V5drVUS')
  })
  // Let the seals in!!
  focaBot.establishConnection()
  focaBot.log(`--- Started (${new Date()}) ---`)
})

require('dotenv').config()
require('coffeescript/register')

const path = require('path')
const ffmpeg = require('ffmpeg-downloader')
const Azarasi = require('azarasi')

const focaBot = new Azarasi({
  name: 'FocaBot',
  version: '1.0.0-alpha (Elegant Erizo)',
  prefix: process.env.BOT_PREFIX,
  token: process.env.BOT_TOKEN,
  owner: JSON.parse(process.env.BOT_OWNER),
  admins: JSON.parse(process.env.BOT_ADMINS),
  adminRoles: JSON.parse(process.env.BOT_ADMIN_ROLES),
  djRoles: JSON.parse(process.env.BOT_DJ_ROLES),
  debug: !!process.env.DEBUG,
  modulePath: path.join(__dirname, 'modules/'),
  localePath: path.join(__dirname, 'locales/'),
  locale: 'en_US',
  watch: true,
  dbFile: process.env.DB_FILE || 'data.db',
  dbPort: process.env.DB_PORT || 12920,
  ffmpegBin: ffmpeg.path
})

// These modules go first.
focaBot.modules.load(['util'])

// Common parameters
focaBot.settings.register('autoDel', { type: Boolean, def: true })

// Load the translations
const translations = ['ar_SA', 'de_DE', 'en_US', 'es_ES', 'fr_FR', 'ja_JP', 'pt_PT']
translations.forEach(t => focaBot.locales.loadLocale(t))

// Load the modules.
focaBot.modules.load(JSON.parse(process.env.BOT_MODULES))

// Let the seals in!!
focaBot.establishConnection()

focaBot.log(`Shard ${Core.shard.id || 0} started!`)

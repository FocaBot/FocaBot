require('coffeescript/register')
const Azarasi = require('azarasi')
const ffmpeg = require('ffmpeg-downloader')
const fs = require('fs')
const path = require('path')

const home = process.env[(process.platform === 'win32') ? 'USERPROFILE' : 'HOME']
const dataPath = path.join(home, '.focaBot')
const configFile = path.join(dataPath, 'settings.json')

const config = JSON.parse(fs.readFileSync(configFile, 'utf-8'))

Object.assign(process.env, config.env)

// Instantiate the bot
const focaBot = new Azarasi({
  name: 'FocaBot',
  version: '1.1.0 (Fabulous Flamenco)',
  token: config.token,
  prefix: config.prefix,
  adminRoles: [ config.adminRole ],
  djRoles: [ config.djRole ],
  modulePath: path.join(__dirname, '../modules/'),
  localePath: path.join(__dirname, '../locales/'),
  locale: config.defaultLocale,
  dbFile: path.join(dataPath, 'data.db'),
  dbPort: config.dbPort || 12920,
  ffmpegBin: config.ffmpegPath || ffmpeg.path,
  ffprobeBin: config.ffprobePath || ffmpeg.probePath,
  npm: true
})

// Parameters
focaBot.settings.register('autoDel', { type: Boolean, def: true })
// Modules
focaBot.modules.load(['util', 'admin'])
focaBot.modules.load(config.modules)
// Translations
const translations = ['ar_SA', 'cs_CZ', 'de_DE', 'en_US', 'eo_UY', 'es_ES', 'fr_FR', 'it_IT', 'ko_KR', 'nl_NL', 'ja_JP', 'pt_PT', 'pl_PL']
translations.forEach(t => focaBot.locales.loadLocale(t))

// Invite Link
if (!Core.shard.id || Core.shard.id === 0) {
  focaBot.bot.on('ready', async () => {
    if (!focaBot.bot.user.bot) {
      focaBot.log('Running FocaBot in a non-bot user account. This is discouraged.', 2)
      focaBot.properties.owner = [ focaBot.bot.user.id ]
      return
    }
    try {
      const app = await focaBot.bot.fetchApplication()
      focaBot.log('To add the bot to your server, use this link: ')
      focaBot.properties.owner = [ app.owner.id ]
      focaBot.permissions.owner = focaBot.properties.owner
      focaBot.log(`https://discordapp.com/oauth2/authorize?client_id=${app.id}&scope=bot&permissions=57408`)
    } catch (e) {}
  })
}

// Let the seals in!!
focaBot.establishConnection()

if (Core.shard.id) {
  focaBot.log(`Shard ${Core.shard.id} started!`)
} else {
  focaBot.log(`Started!`)
}

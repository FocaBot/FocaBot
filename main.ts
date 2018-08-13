import { Azarasi } from 'azarasi'
import { FocaBotConfig } from './types/focabot/config'
import yaml from 'js-yaml'
import path from 'path'
import fs from 'fs'

// CoffeeScript module support
require('coffeescript').register()

// Load Config
const configFile = path.join(__dirname, 'focabot.yml')
const config = yaml.safeLoad(fs.readFileSync(configFile, 'utf-8')) as FocaBotConfig

const focaBot = new Azarasi({
  name: 'FocaBot@dev',
  version: '2.0.0-alpha',
  versionName: 'Glorious Gato',
  prefix: config.bot.prefix,
  token: config.bot.token,
  owner: config.bot.owners,
  admins: config.bot.globalAdmins,
  adminRoles: config.roles.admin,
  djRoles: config.roles.dj,
  debug: config.bot.debug,
  modulePath: path.join(__dirname, 'modules'),
  localePath: path.join(__dirname, 'locales'),
  locale: config.bot.locale,
  watch: true,
  dbFile: config.data.gun.file,
  dbPort: config.data.gun.port,
  redisUrl: config.data.redis.server,
  dataStore: config.data.backend,
  focaBot: config
})
// Load the translations
const translations = [
  'ar_SA',
  'cs_CZ',
  'de_DE',
  'en_US',
  'eo_UY',
  'es_ES',
  'fr_FR',
  'ja_JP',
  'ko_KR',
  'nl_NL',
  'pt_PT'
]

translations.forEach(t => focaBot.locales.loadLocale(t))

// Load modules
focaBot.modules.load(config.modules)

// Let the seals in!!
focaBot.establishConnection()

focaBot.log('Started!')
focaBot.events.once('ready', () => {
  if (!focaBot.bot.user.bot) {
    focaBot.log('Running FocaBot in a non-bot user account. This is discouraged.', 2)
  }
})

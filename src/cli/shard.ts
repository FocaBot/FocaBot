import { Azarasi } from 'azarasi'
import { loadConfig, version, versionName } from './common'
import path from "path"

loadConfig(process.env.FOCABOT_CONFIG).then(async (config) => {
  const focaBot = new Azarasi({
    name: 'FocaBot',
    version,
    versionName,
    prefix: config.bot.prefix,
    token: config.bot.token,
    owner: config.bot.owners,
    admins: config.bot.globalAdmins,
    adminRoles: config.roles.admin,
    djRoles: config.roles.dj,
    debug: process.env.FOCABOT_DEBUG === '1' || config.bot.debug,
    modulePath: path.join(__dirname, '..', 'modules'),
    localePath: path.join(__dirname, '..', '..', 'locales'),
    locale: config.bot.locale,
    watch: true,
    dbPath: config.data.gun.path,
    dbPort: config.data.gun.port,
    redisUrl: config.data.redis.server,
    couchdbUrl: config.data.couchdb.server,
    couchdbDatabase: config.data.couchdb.dbName,
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

  // Expose the main instance to the shard manager
  if (focaBot.shard) {
    // @ts-ignore
    global.FocaBot = focaBot
  }

  // Let the seals in!!
  focaBot.establishConnection()

  focaBot.log('Started!')
})

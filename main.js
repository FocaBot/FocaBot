require('dotenv').config()
require('coffeescript/register')

const path = require('path')
const Azarasi = require('azarasi')

const focaBot = new Azarasi({
  name: 'FocaBot',
  version: '1.0.0-dev (Elegant Erizo)',
  prefix: process.env.BOT_PREFIX,
  token: process.env.BOT_TOKEN,
  owner: JSON.parse(process.env.BOT_OWNER),
  admins: JSON.parse(process.env.BOT_ADMINS),
  adminRoles: JSON.parse(process.env.BOT_ADMIN_ROLES),
  djRoles: JSON.parse(process.env.BOT_DJ_ROLES),
  // shardCount: env.NODE_APP_INSTANCE ? os.cpus().length : undefined,
  // shardIndex: env.NODE_APP_INSTANCE ? parseInt(env.NODE_APP_INSTANCE) : undefined,
  debug: !!process.env.DEBUG,
  modulePath: path.join(__dirname, 'modules/'),
  localePath: path.join(__dirname, 'locales/'),
  locale: 'es_ES',
  redisURL: process.env.REDIS_URL,
  watch: true
})

// These modules go first.
// focaBot.modules.load(['config', 'util'])
// Load the modules.
focaBot.modules.load(JSON.parse(process.env.BOT_MODULES))

// Let the seals in!!
focaBot.establishConnection()

focaBot.log(`--- Started (${new Date()}) ---`)

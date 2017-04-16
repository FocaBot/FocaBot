require('dotenv').config()
require('coffeescript/register')
const os = require('os')
const path = require('path')
const FocaBotCore = require('focabot-core')
const { env } = process

const focaBot = new FocaBotCore({
  name: 'FocaBot',
  version: '0.6.1 (Dangerous Dodo)',
  prefix: env.BOT_PREFIX,
  token: env.BOT_TOKEN,
  owner: JSON.parse(env.BOT_OWNER),
  admins: JSON.parse(env.BOT_ADMINS),
  adminRoles: JSON.parse(env.BOT_ADMIN_ROLES),
  djRoles: JSON.parse(env.BOT_DJ_ROLES),
  shardCount: env.NODE_APP_INSTANCE ? os.cpus().length : undefined,
  shardIndex: env.NODE_APP_INSTANCE ? parseInt(env.NODE_APP_INSTANCE) : undefined,
  debug: false,
  modulePath: path.join(__dirname, 'modules/'),
  redisURL: env.REDIS_URL,
  watch: true
})

// These modules go first.
focaBot.modules.load(['config', 'util'])
// Load the modules.
focaBot.modules.load(JSON.parse(env.BOT_MODULES))

// Let the seals in!!
focaBot.establishConnection()

console.log(`--- Started (${new Date()}) ---`)

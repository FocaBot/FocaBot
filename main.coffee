dotenv = require 'dotenv'
dotenv.config()

BotEngine = require './core'
mkdirp = require 'mkdirp'


botSettings =
  name: 'FocaBot'
  prefix: process.env.BOT_PREFIX
  token: process.env.BOT_TOKEN
  owner: JSON.parse process.env.BOT_OWNER
  admins: JSON.parse process.env.BOT_ADMINS
  adminRoles: JSON.parse process.env.BOT_ADMIN_ROLES
  djRoles: JSON.parse process.env.BOT_DJ_ROLES

focaBot = new BotEngine botSettings

# Run this shit
focaBot.establishConnection()
# Load Modules
focaBot.modules.load JSON.parse process.env.BOT_MODULES

console.log 'Started.'

botEngine = require './core'
dotenv = require 'dotenv'
mkdirp = require 'mkdirp'

mkdirp 'data/tmp'
dotenv.config()
botSettings =
  prefix: process.env.BOT_PREFIX
  token: process.env.BOT_TOKEN
  owner: JSON.parse process.env.BOT_OWNER
  admins: JSON.parse process.env.BOT_ADMINS
  adminRoles: JSON.parse process.env.BOT_ADMIN_ROLES

midiBot = new botEngine botSettings

# Run this shit
midiBot.establishConnection()
# Load Modules
midiBot.modules.load JSON.parse process.env.BOT_MODULES

console.log 'done'

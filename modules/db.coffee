# RethinkDB Module for FocaBotCore
# Must be loaded before all other modules that use DB.

class DataBaseModule extends BotModule
  init: =>
    Core.db = require('thinky') {
      host: process.env.DB_HOST
      port: process.env.DB_PORT
      authKey: process.env.DB_AUTH
      db: process.env.DB_NAME
      user: process.env.DB_USER
      password: process.env.DB_PASS
    }

module.exports = DataBaseModule

thinky = require('thinky') {
  host: process.env.DB_HOST
  port: process.env.DB_PORT
  authKey: process.env.DB_AUTH
  db: process.env.DB_NAME
}

module.exports = thinky

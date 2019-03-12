#!/bin/env node
const fs = require('fs')
const path = require('path')

if (fs.existsSync(path.join(__dirname, 'build'))) {
  require('./build/cli')
} else {
  console.error('Build files missing! Please execute "npm run build" and try again.')
}

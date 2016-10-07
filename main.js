require('coffee-script/register');
require('dotenv').config();
const BotEngine = require('./core');

const FocaBot = new BotEngine({
  name: 'FocaBot',
  prefix: process.env.BOT_PREFIX,
  token: process.env.BOT_TOKEN,
  owner: JSON.parse(process.env.BOT_OWNER),
  admins: JSON.parse(process.env.BOT_ADMINS),
  adminRoles: JSON.parse(process.env.BOT_ADMIN_ROLES),
  djRoles: JSON.parse(process.env.BOT_DJ_ROLES),
});

FocaBot.modules.load(JSON.parse(process.env.BOT_MODULES));
FocaBot.establishConnection();
console.log('Started');

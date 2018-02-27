require('dotenv').config()
const Discord = require('discord.js')

console.log(`
       .-.
      :   ;
       "."               FocaBot v1.0.1 (Elegant Erizo)
       / \\               by > thebit.link
      /  |
    .'    \\
   /.'   \`.\\             Documentation: https://www.focabot.xyz/
   ' \\    \`\`.            Support Server: https://discord.gg/V5drVUS
     _\`.____ \`-._        GitHub: https://www.github.com/FocaBot/
    /^^^^^^^^\`.\\^\\
   /           \`  \\
""""""""""""""""""""""""
`)

const ShardManager = new Discord.ShardingManager('shard.js', {
  token: process.env.BOT_TOKEN
})

ShardManager.spawn()
.catch(e => {
  console.error('Sharding unavailable, falling back to single-process mode.')
  require('./shard')
})

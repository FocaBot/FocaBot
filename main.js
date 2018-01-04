require('dotenv').config()
const Discord = require('discord.js')

console.log(`
       .-.
      :   ;
       "."               FocaBot v1.0.0-alpha (Elegant Erizo)
       / \\               by > thebit.link
      /  |
    .'    \\
   /.'   \`.\\             Documentation: https://next.focabot.xyz/
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

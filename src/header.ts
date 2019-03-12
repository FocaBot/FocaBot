import fs from 'fs'
import path from 'path'
const packageJson = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'package.json'), 'utf8'))

export const version = packageJson.version
export const versionName = 'Glorious Gato'

export default function printHeader () {
  console.log(`
       .-.
      :   ;
       "."               FocaBot ${version} (${versionName})
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
}

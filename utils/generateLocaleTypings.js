/**
 * Takes a FocaBot locale as input and outputs a TypeScript definition.
 */
const yaml = require('js-yaml')
const path = require('path')
const fs = require('fs')

// Target locale
const targetLocale = 'en_US'
// Input file
const input = path.join(__dirname, '..', 'locales', targetLocale, 'strings.yml')
// Output file
const output = path.join(__dirname, '..', 'types', 'focabot-locale', 'index.d.ts')
// Output header
const header = `/**
 * FocaBot Locale TypeScript Definition
 * Generated automatically from ${targetLocale}/strings.yml on ${(new Date()).toJSON()}
 */
import { Locale } from 'azarasi/lib/locales'
`

const locale = yaml.safeLoad(fs.readFileSync((input), 'utf-8'))
const f = fs.createWriteStream(output, { encoding: 'utf-8', flags: 'w' })

f.write(header)

f.write("\ndeclare module 'azarasi/lib/locales' {\n")
f.write('  interface Locale {')
function generateBlock (block, indent = 4) {
  const indentStr = Array(indent + 1).join(' ')
  for (const key in block) {
    const value = block[key]
    if (typeof value === 'string') {
      f.write(`\n${indentStr}/**\n${value.replace(/^/gm, indentStr + ' * ')}\n${indentStr} */`)
      f.write(`\n${indentStr}"${key}" : string`)
    } else if (value instanceof  Array) {
      f.write(`\n${indentStr}"${key}" : string[]`)
    } else if (typeof  value === 'object') {
      f.write(`\n${indentStr}"${key}" : {`)
      generateBlock(value, indent + 2)
      f.write(`\n${indentStr}}`)
    }
  }
}
generateBlock(locale)
f.write('\n  }\n}\n')
f.close()

console.log(`TypeScript definitions for ${targetLocale} generated successfully!`)

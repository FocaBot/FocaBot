/**
 * Eval module
 */
const { Azarasi } = require('azarasi')
const prune = require('json-prune')
const format = require('json-format')
const reload = require('require-reload')(require)
const CoffeeScript = require('coffeescript')

// Pseudo-global namespace
const G = {}
// Settings for JSON formatting
const formatSettings = { type: 'space', size: 2 }

class Eval extends Azarasi.Module {
  init () {
    // CoffeeScript eval
    this.registerCommand('eval', { ownerOnly: true, allowDM: true }, ({ msg, args }) => {
      const { print, p, json, j } = this.generateUtillityFunctions(msg)
      // Scope input
      const input = `(=>\n${args.replace(/^/gm, '  ')}\n)()`
      // Compile
      const js = CoffeeScript.compile(input, { bare: true })
      // Evaluate
      try {
        eval(js)
      } catch (e) {
        msg.channel.send({
          embed: {
            color: 0xFF0000,
            description: e.message || 'Something went wrong.'
          }
        })
      }
    })

    // JavaScript eval
    this.registerCommand('jseval', { ownerOnly: true, allowDM: true }, ({ msg, args }) => {
      const { print, p, json, j } = this.generateUtillityFunctions(msg)
      // Scope input
      const input = `(async () => {${args}})()`
      // Evaluate
      try {
        eval(input)
      } catch (e) {
        msg.channel.send({
          embed: {
            color: 0xFF0000,
            description: e.message || 'Something went wrong.'
          }
        })
      }
    })
  }

  generateUtillityFunctions (msg) {
    // Print (reply)
    const print = (...args) => msg.channel.send(...args)
    // JSON print
    const json = (obj, depth = 2) => {
      const pruned = prune(obj, depth)
      msg.channel.send('```json\n' + format(pruned, formatSettings) + '\n```')
    }
    return {
      print,
      p: print,
      json,
      j: json
    }
  }
}

module.exports = Eval

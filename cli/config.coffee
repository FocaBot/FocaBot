iq = require 'inquirer'
prompts = require './prompts'
fs = require 'fs'
done = false

module.exports =(config, file)->
  console.log ''
  while not done
    { param } = await iq.prompt [{
      name: 'param'
      message: 'What do you want to do?'
      type: 'list'
      choices: [
        { name: 'Change the bot token', value: 'token' }
        { name: "Change the command prefix (#{config.prefix})", value: 'prefix' }
        { name: 'Change the modules loaded at startup', value: 'modules' }
        { name: "Change the owner ID (#{config.owner})", value: 'owner' }
        { name: "Change the DJ role name (#{config.djRole})", value: 'djRole' }
        { name: "Change the Admin role name (#{config.adminRole})", value: 'adminRole' }
        {
          name: "Change the default language (#{config.defaultLocale})",
          value: 'defaultLocale'
        }
        new iq.Separator()
        { name: 'Save changes and exit', value: 'wq' }
        { name: 'Discard changes and exit', value: 'q' }
        new iq.Separator()
      ]
    }]
    switch param
      when 'q' then done = true
      when 'wq'
        fs.writeFileSync(file, JSON.stringify(config), 'utf-8')
        done = true
      else
        r = await iq.prompt [ prompts[param] ]
        config[param] = r[param]

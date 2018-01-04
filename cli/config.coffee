iq = require 'inquirer'
prompts = require './prompts'
fs = require 'fs'
done = false

module.exports =(config, file)->
  console.log ''
  menu = 'main'
  while not done
    { param } = await iq.prompt [{
      name: 'param'
      message:
        if menu is 'main' then 'What do you want to do?'
        else if menu is 'apiKeys' then ->
          console.log '''
          API keys allow FocaBot to do stuff using third party services.

          They're not required for the bot to function, but if you want to enable\
          certain modules, such as the "image" module or the "osu!" module, you'll have\
          to set them up first.
          '''
          'What do you want to do?'
      type: 'list'
      choices:
        if menu is 'main'
          [
            { name: 'Change the bot token', value: 'token' }
            { name: "Change the command prefix (#{config.prefix})", value: 'prefix' }
            { name: 'Change the modules loaded at startup', value: 'modules' }
            { name: "Change the DJ role name (#{config.djRole})", value: 'djRole' }
            { name: "Change the Admin role name (#{config.adminRole})", value: 'adminRole' }
            {
              name: "Change the default language (#{config.defaultLocale})",
              value: 'defaultLocale'
            }
            { name: "Change internal database port (#{config.dbPort||12920})", value: 'dbPort' }
            new iq.Separator()
            { name: 'Set up additional API keys >', value: 'apiKeys' }
            new iq.Separator()
            { name: 'Save changes and exit', value: 'wq' }
            { name: 'Discard changes and exit', value: 'q' }
            new iq.Separator()
          ]
        else if menu is 'apiKeys'
          [
            { name: 'Configure Google CSE keys', value: 'googleKeys' }
            { name: 'Configure Imgur API key', value: 'imgurKeys' }
            { name: 'Configure Danbooru API key', value: 'danbooruKeys' }
            { name: 'Configure Tumblr consumer key', value: 'tumblrKeys' }
            { name: 'Configure osu! API key', value: 'osuKeys' }
            new iq.Separator()
            { name: '< Go back', value: 'back' }
            new iq.Separator()
            { name: 'Save changes and exit', value: 'wq' }
            { name: 'Discard changes and exit', value: 'q' }
            new iq.Separator()
          ]
    }]
    switch param
      when 'apiKeys'
        menu = 'apiKeys'
      when 'back'
        menu = 'main'
      when 'q' then done = true
      when 'wq'
        fs.writeFileSync(file, JSON.stringify(config), 'utf-8')
        done = true
      else
        prompt = prompts[param]
        prompt = prompt(config, true) if typeof prompt is 'function'
        prompt = [ prompt ] if not prompt instanceof Array
        r = await iq.prompt [ prompt ]
        console.log(r)
        Object.assign(config, r)

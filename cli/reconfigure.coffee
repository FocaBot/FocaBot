iq = require 'inquirer'
prompts = require './prompts'

module.exports =->
  console.log '''
  FocaBot needs a Discord Bot Token in order to work.

  If you don't know how to get one, follow these steps:
  1. Go to https://discordapp.com/developers/applications/me
  2. Create a new application. Name it FocaBot (or however you want)
  3. Inside the application details page, click "Create a Bot User"
  4. Click the link to reveal the token
  5. Paste the token below
  
  Please keep your token in a safe place, it's like a password for bot accounts.\n
  '''
  { token } = await iq.prompt [ prompts.token ]
  console.log '''
  \nPlease set a global command prefix.

  This will be used by default on servers that don't have a custom prefix.

  If unsure, press enter to use the default (f'play, f'skip, f'help, etc)\n
  '''
  { prefix } = await iq.prompt [ prompts.prefix ]
  console.log """
  \nFocaBot has many functions, but most of them are optional

  Pro Tip: You can use the #{prefix}disable {module} or #{prefix}enable {module} commands \
  to disable or enable modules per-server.

  Please select the modules you want FocaBot to load at startup then press enter.
  (If you disable a module here, it won't be available even with the #{prefix}enable command)\n
  """
  { modules } = await iq.prompt [ prompts.modules({}, false) ]
  console.log '''
  \nIf you create a role with "DJ" as name, FocaBot will detect such role and users \
  with that role will have full access to music commands \
  (instant skip, filters, queue management, etc)

  Press Enter if you want to keep the default name (DJ), otherwise enter a custom role name\n
  '''
  { djRole } = await iq.prompt [ prompts.djRole ]
  console.log """
  \nIf you create a role with "Bot Commander" as name, FocaBot will detect such role and users \
  with that role will have full access to music and administrative commands \
  (#{prefix}config, #{prefix}enable, #{prefix}disable, etc)

  Press Enter if you want to keep the default name (Bot Commander), otherwise \
  enter a custom role name\n
  """
  { adminRole } = await iq.prompt [ prompts.adminRole ]
  console.log """
  \nFocaBot has been translated by the community to some other languages.

  You can select a default language for the bot that can be changed on each server \
  using the #{prefix}config locale {language code} command!

  If you want to help with translations, feel free to DM me on Discord (@TheBITLINK#3141)

  Please select a default language for the bot\n
  """
  { defaultLocale } = await iq.prompt [ prompts.defaultLocale ]
  console.log '''
  \n\nDone! FocaBot has been successfully set up!

  Don't forget to check the documentation to learn how to further customize it!

  If in the future you want to change one of the parameters, or enable additional modules, \
  run "focabot config" in your terminal.\n
  '''
  return { token, prefix, modules, djRole, adminRole, defaultLocale }

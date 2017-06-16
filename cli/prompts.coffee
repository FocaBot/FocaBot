module.exports =
  token:
    name: 'token'
    message: 'Bot Token:'
    validate: (token)-> /^\S{24}\.\S{6}\.\S{27}$/.test(token)
  prefix:
    name: 'prefix'
    message: 'Global Command Prefix:'
    validate: (pfx)-> pfx.trim().length isnt 0 and pfx.trim().length < 5
    default: "f'"
  modules:
    name: 'modules'
    message: 'Modules to load at startup:'
    type: 'checkbox'
    choices: [
      { name: 'danbooru (Anime Picture Search)', value: 'danbooru', checked: true }
      { name: 'dynamicNick (Dynamic Nickname)', value: 'dynamicNick', checked: true }
      { name: 'eval (Run code)', value: 'eval', checked: true }
      { name: 'greet (Welcomes new users)', value: 'greet', checked: true }
      { name: 'help (Help command)', value: 'help', checked: true }
      { name: 'ping (Pong!)', value: 'ping', checked: true }
      { name: 'player (Music Player)', value: 'player', checked: true }
      { name: 'poll (Simple Polls)', value: 'poll', checked: true }
      { name: 'raffle (Simple Raffle System)', value: 'raffle', checked: true }
      { name: 'rng (Dice Rolls, 8ball, etc)', value: 'rng', checked: true }
      { name: 'seal (Sends seal pictures)', value: 'seal', checked: true }
      { name: 'statics (Shows bot statics)', value: 'statics', checked: true }
      { name: 'tags (Custom tags/quotes)', value: 'tags', checked: true }
    ]
  owner:
    name: 'owner'
    message: 'Bot Owner User ID:'
    validate: (id)-> /^\d{18,}$/.test(id)
  djRole:
    name: 'djRole'
    message: 'DJ Role Name:'
    default: 'DJ'
    validate: (name)-> name.trim().length isnt 0 and name.trim().length < 32
  adminRole:
    name: 'adminRole'
    message: 'Admin Role Name:'
    default: 'Bot Commander'
    validate: (name)-> name.trim().length isnt 0 and name.trim().length < 32
  defaultLocale:
    name: 'defaultLocale'
    message: 'Default Language:'
    type: 'list'
    default: 'en_US'
    choices: ['ar_SA', 'en_US', 'es_ES', 'fr_FR']

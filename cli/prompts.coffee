module.exports =
  token:
    name: 'token'
    message: 'Bot Token:'
    validate: (token)-> /^(\S{24}\.\S{6}\.\S{27}|mfa\.\S+)$/.test(token)
  prefix:
    name: 'prefix'
    message: 'Global Command Prefix:'
    validate: (pfx)-> pfx.trim().length isnt 0 and pfx.trim().length < 5
    default: "f'"
  modules: (config, advanced) ->
    choices = [
      { name: 'danbooru (Anime Picture Search)', value: 'danbooru', checked: true }
      { name: 'dynamicNick (Dynamic Nickname)', value: 'dynamicNick', checked: true }
      { name: 'eval (Run code)', value: 'eval', checked: true }
      { name: 'greet (Welcomes new users)', value: 'greet', checked: true }
      { name: 'help (Help command)', value: 'help', checked: true }
      { name: 'ping (Pong!)', value: 'ping', checked: true }
      { name: 'player (Music Player)', value: 'player', checked: true }
      { name: 'playlists (Manage playlists inside the bot)', value: 'playlists', checked: true }
      { name: 'poll (Simple Polls)', value: 'poll', checked: true }
      { name: 'raffle (Simple Raffle System)', value: 'raffle', checked: true }
      { name: 'rng (Dice Rolls, 8ball, etc)', value: 'rng', checked: true }
      { name: 'seal (Sends seal pictures)', value: 'seal', checked: true }
      { name: 'statics (Shows bot statics)', value: 'statics', checked: true }
      { name: 'tags (Custom tags/quotes)', value: 'tags', checked: true }
      { name: 'inlineCommands (Inline Commands)', value: 'inlineCommands', checked: true }
    ]
    if config.env?
      if config.env.GOOGLE_KEY or config.env.IMGUR_KEY or config.env.TUMBLR_CONSUMER_KEY
        choices.push { name: 'image (Image search)', value: 'image', checked: false }
      if config.env.OSU_KEY
        choices.push { name: 'osu (osu! player statics)', value: 'osu', checked: false }
    if advanced
      choices.push { name: 'eval (Evaluate CoffeeScript)', value: 'eval', checked: false }
      choices.push { name: 'announcements (Make announcements)', value: 'eval', checked: false }
    if config.modules? then choices.forEach (module)->
      module.checked = config.modules.indexOf(module.value) >= 0
    return {
      name: 'modules'
      message: 'Modules to load at startup:'
      type: 'checkbox'
      choices
    }
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
    choices: ['ar_SA', 'cs_CZ', 'de_DE', 'en_US', 'es_ES', 'fr_FR', 'ja_JP', 'nl_NL', 'pt_PT']
  dbPort:
    name: 'dbPort'
    message: 'Internal Database Port:'
    default: 12920
    validate: (v)-> typeof v is 'number'
  # API Keys
  googleKeys: [
    {
      name: 'env.GOOGLE_CX'
      message: ->
        console.log '''
        The image search commands make use of Google's custom search API.

        Two keys are required to use this API, a custom search engine id (CX) \
        and a Google API key.

        First, we'll configure the Custom Search Engine ID (CX).

        To get one, follow these steps:
        - Go to https://www.google.com/cse/manage/all
        - Create a new search engine. Put whatever you want in the site URL.
        - Go to the control panel of the newly created CSE.
        - Under "Sites to search", select "Search the entire web but emphasize included sites".
        - Under Details, click "Search engine ID". Copy this value and paste it below.

        '''
        'Google CX'
      validate: (key)-> /^\S+$/.test(key.trim())
    }
    {
      name: 'env.GOOGLE_KEY'
      message: ->
        console.log '''
        Now, we'll configure the Google API key.

        To get one, follow these steps:
        - Go to https://console.developers.google.com/
        - Create a new project, then click on "Add APIs and services".
        - Search for the "Custom Search API" and enable it.
        - Go to "credentials" to get the API key, copy it, and paste it below.

        '''
        'Google API Key'
      validate: (key)-> /^\S+$/.test(key.trim())
    }
  ]
  imgurKeys:
    name: 'env.IMGUR_KEY'
    message: ->
      console.log '''
      The Imgur command requires an API key.

      To get one, follow these steps:
      - Register a new OAuth2 app at https://api.imgur.com/oauth2/addclient
      - Use https://www.focabot.xyz/ as callback URL
      - Copy the client id and paste it below.

      '''
      'Imgur Client ID'
    validate: (key)-> /^\S+$/.test(key.trim())
  danbooruKeys: [
    {
      name: 'env.DANBOORU_LOGIN'
      message: ->
        console.log '''
        Danbooru is an anime focused imageboard.
        FocaBot includes a few commands that allow searching images in the site.

        However, anonymous searches are limited to 2 tags at a time.
        If you have a Danbooru Gold account or higher, you can bypass \
        this limit using an API key.

        Note that setting these has no effect if you have a free or basic account. \
        The limit will stay the same.

        '''
        'Danbooru Username'
    }
    {
      name: 'env.DANBOORU_API_KEY'
      message: ->
        console.log '''
        You can get your API key under your account settings.
        '''
        'Danbooru API Key'
      validate: (key)-> /^\S+$/.test(key.trim())
    }
  ]
  tumblrKeys:
    name: 'env.TUMBLR_CONSUMER_KEY'
    message: ->
      console.log '''
      FocaBot includes a command to search images on tumblr.

      You'll need a tumblr OAuth consumer key.

      To get one, follow these steps:
      - Register a new OAuth app at https://www.tumblr.com/oauth/register
      - Use https://www.focabot.xyz/ as website and callback URL
      - Copy the consumer key and paste it below.

      '''
      'Tumblr Consumer Key'
    validate: (key)-> /^\S+$/.test(key.trim())
  osuKeys:
    name: 'env.OSU_KEY'
    message: ->
      console.log '''
      FocaBot includes some commands that provide statics for osu! players.

      You'll need to provide an osu! API key

      To get one, go to https://osu.ppy.sh/p/api and register an app.

      '''
      'osu! API key'
    validate: (key)-> /^\S+$/.test(key.trim())

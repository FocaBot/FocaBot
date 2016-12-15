# FocaBot [![Chat](https://img.shields.io/badge/chat-on%20discord-7289da.svg)](https://discord.gg/V5drVUS)
<p align="center"><img src="https://cdn.discordapp.com/attachments/248274146931245056/257629105862737921/unknown.png" alt="Logo"></p>
FocaBot is an advanced music bot for discord, it includes most of the commands
you would expect for a music but, plus some extras, like a `seek` command, many
audio filters (`| nightcore`, anyone?), and advanced queue management (`move`, `swap`, `remove`)

It includes some non-music related modules as well, like a tag system, configurable server greetings,
Google Images, Danbooru and Imgur search, among other stuff.

It's built on top of the [FocaBotCore](https://github.com/FocaBot/FocaBotCore) framework
and [Discordie](https://qeled.github.io/discordie/). It's easy to create your own modules.

## Local Installation

You'll likely need the following things:

 - [Node.js v7](https://nodejs.org/es/) (v6 will likely not work)
 - [RethinkDB](https://www.rethinkdb.com/)
 - [FFMpeg](https://ffmpeg.org/)
 - [A Discord Bot Token](https://discordapp.com/developers/applications/me)
 - [Some API keys if you want the additional stuff](.env.example)

Follow these steps:

 - Clone or download this repo to a folder in your system
 - Run `npm install` on said folder
 - Rename the `.env.example` file to `.env` and fill it with the required stuff
   - `BOT_TOKEN`: A discord bot token. You can get one [here](https://discordapp.com/developers/applications/me).
   - `BOT_PREFIX`: The default Command Prefix. If you set it to `!` i'll find you and kill you.
   - `BOT_OWNER`: Here you put the user IDs of the accounts that will have full access to the bot.
   - `BOT_MODULES`: List of modules you want to be loaded.
   - `BOT_ADMINS`: The IDs here will have access to admin commands across all guilds
   - `BOT_ADMIN_ROLES`: Users with these roles will have administrative access on their guilds.
   - `BOT_DJ_ROLES`: Users with these roles will have full control over the queue and instant skip.
   - The other fields are optional
 - Make sure RethinkDB is running before starting up the bot
 - Run `npm start`

## Documentation

To learn more about the available commands and filters, check the [documentation](https://thebitlink.gitbooks.io/focabot-docs/).

## Official discord server

If you have problems with the bot or some feature requests, feel free to come to the [official discord server](https://discord.gg/V5drVUS)

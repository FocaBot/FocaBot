const Discordie = require('discordie');
const CommandManager = require('./commands');
const ModuleManager = require('./modules');
const PermissionManager = require('./permissions');
const GuildManager = require('./guilds');
const WebHookCollection = require('./webHooks');
const BotUtils = require('./utils');
const BotException = require('./exceptions');
const git = require('git-rev');

class BotEngine {
  constructor(settings) {
    this.settings = settings;
    this.prefix = settings.prefix;
    this.name = settings.name;
    this.version = 'dev-0.5.1';

    this.bot = new Discordie({ autoReconnect: true });
    this.guildData = new GuildManager(this);
    this.permissions = new PermissionManager(this);
    this.commands = new CommandManager(this);
    this.modules = new ModuleManager(this);
    this.webHooks = new WebHookCollection(this);
    this.utils = BotUtils;
    this.BotException = BotException;

    this.bot.Dispatcher.on('GATEWAY_READY', e => this.onReady(e));
    this.bot.Dispatcher.on('MESSAGE_CREATE', e => this.onMessage(e));

    this.bootDate = new Date();
    global.core = this;
  }

  onReady() {
    this.bot.User.setStatus('dnd', {
      name: `${this.prefix}help [${this.version}]`,
    });
    console.log('Ready!');
  }

  onMessage(e) {
    if (e.message.content.indexOf(this.prefix) === 0) {
      this.commands.executeCommand(e.message);
    }
  }

  establishConnection() {
    this.bot.connect({ token: this.settings.token });
  }

  getGuildData(guild) {
    return this.guildData[guild.id] || this.guildData.addGuild(guild);
  }
}

module.exports = BotEngine;

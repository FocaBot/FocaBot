class BotCommand {
  constructor(engine, name, options, func) {
    this.engine = engine;
    this.bot = engine.bot;
    this.name = name;
    this.aliases = options.aliases || [];
    this.adminOnly = options.djOnly || false;
    this.ownerOnly = options.ownerOnly || false;
    this.argSeparator = options.argSeparator || null;
    this.includeCommandNameInArgs = options.includeCommandNameInArgs || false;
    this.func = func;
  }

  exec(msg, args) {
    this.func(msg, args, this.bot, this.engine);
  }
}

class BotCommandManager {
  constructor(engine) {
    this.engine = engine;
    this.prefix = engine.prefix;
    this.permissions = engine.permissions;
    this.registered = {};
    this.registeredPlain = {};
  }

  registerCommand(name, opt, func) {
    if (!name) return null;
    const command = (typeof opt === 'function')
                  ? new BotCommand(this.engine, name, {}, opt)
                  : new BotCommand(this.engine, name, opt, func);
    this.registered[name] = command;
    this.registeredPlain[name] = command;
    for (const alias of command.aliases) {
      this.registeredPlain[alias] = command;
    }
    return command;
  }

  unregisterCommand(cmd) {
    const command = (typeof cmd === 'string')
                  ? this.registered[cmd]
                  : cmd;
    if (!command) return false;
    delete this.registered[command.name];
    delete this.registeredPlain[command.name];
    for (const alias of command.aliases) {
      delete this.registeredPlain[alias];
    }
    return true;
  }

  unregisterCommands(cmds) {
    for (const command of cmds) {
      this.unregisterCommand(command);
    }
  }

  executeCommand(msg) {
    
  }
}
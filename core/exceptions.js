class BotException {
  constructor(message, code=1) {
    this.message = message;
    this.code = code;
  }
}

module.exports = BotException;
global.BotException = BotException;

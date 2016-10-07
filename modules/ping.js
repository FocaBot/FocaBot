class PingModule extends BotModule {
  init() {
    this.registerCommand('ping', async (msg) => {
      const pingMsg = await msg.channel.sendMessage('Pong!');
      pingMsg.edit(`Pong! \`${new Date(pingMsg.timestamp) - new Date(msg.timestamp)}ms\``);
    });
  }
}

module.exports = PingModule;

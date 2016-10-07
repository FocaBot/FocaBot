class GuildAudioPlayer {
  constructor(engine, guild) {
    this.engine = engine;
    this.guild = guild;
    this.voulme = 50;
    this.currentOffset = 0;
  }

  async play(audioChannel, path, flags, currentOffset = 0) {
    if (this.currentStream) throw new BotException('Bot is already playing another file');
    this.currentOffset = currentOffset;

    await this.join(audioChannel);
    this.currentStream = await this.voiceConnection.createExternalEncoder({
      type: 'ffmpeg',
      source: path,
      format: 'opus',
      inputArgs: flags.input,
      outputArgs: flags.output,
    });
    this.encStream = this.currentStream.play();
    this.encStream.resetTimestamp();

    this.currentStream.on('end', () => this.clean());
    return this.currentStream;
  }

  async join(audioChannel) {
    if (this.voiceConnection) {
      if (this.voiceConnection.channelId !== audioChannel.id) {
        throw new BotException('Bot is already in another voice channel.');
      } else {
        return this.voiceConnection;
      }
    }
    const info = await audioChannel.join();
    this.voiceConnection = info.voiceConnection;
    return this.voiceConnection;
  }

  getTimestamp() {
    if (!this.encStream) return 0;
    return this.encStream.timestamp + this.currentOffset;
  }

  stop() {
    this.currentStream.stop();
    this.clean();
  }

  clean(disconnect = false) {
    delete this.currentStream;
    delete this.encStream;
    if (disconnect) {
      this.voiceConnection.disconnect();
      delete this.voiceConnection;
    }
  }
}

module.exports = GuildAudioPlayer;

class helpModule
  constructor: (@engine)->
    {@bot, @commands, @prefix} = @engine
    # help Command
    helpOptions =
      description: 'Displays help about FocaBot'
    @helpCommand = @commands.registerCommand 'help', helpOptions, @helpCommandFunction

  helpCommandFunction: (msg, args)=>
    reply = """
    **FocaBot Beta #{@engine.version} (#{@engine.versionName})**
    Made by <@164588804362076160>
    
    This bot is not yet public, but you can send me a DM if you want it on your server.

    Command List:
    ```
    Available to Everyone:
    #{@prefix}play    <link/title> - Plays the requested
    #{@prefix}queue                - Shows the current play queue
    #{@prefix}help                 - Shows this help
    #{@prefix}stats                - Technical stuff about the bot
    #{@prefix}ping                 - Pong!

    Bot Commanders:
    #{@prefix}volume  <vol>        - Sets volume of the bot
    #{@prefix}skip                 - Skips currently playing MIDI
    #{@prefix}pause                - Pauses MIDI playback
    #{@prefix}resume               - Resumes MIDI playback
    #{@prefix}stop                 - Stops MIDI playback an clears the queue
    #{@prefix}disable              - "Disables" the bot (will only accept commands from Bot Commanders)
    #{@prefix}enable               - Enables the bot
    #{@prefix}setnick              - Sets the nickname of the bot
    #{@prefix}clean                - Deletes messages sent by the bot (requires permission to do so)

    Owner:
    [It's a secret to everyone]
    ```
    """
    @bot.sendMessage msg.author, reply
    @bot.reply msg, 'Check your DMs!' if msg.channel.server?

  shutdown: =>
    @commands.unregisterCommand @helpCommand

module.exports = helpModule

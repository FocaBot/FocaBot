class HelpModule extends BotModule
  init: =>
    {@prefix} = @engine
    @registerCommand 'help', @helpCommandFunction
    @registerCommand 'filters', @filtersCommandFunction

  helpCommandFunction: (msg, args)=>
    reply = """
    **#{@engine.name} #{@engine.version} (#{@engine.versionName})**
    Made by <@164588804362076160>
    
    This bot is not yet public, though you can send me a DM if you want it on your server.

    Command List:
    ```
    Available to Everyone:
    #{@prefix}play    <link/title> - Plays the requested song
    #{@prefix}queue                - Shows the current song queue
    #{@prefix}skip                 - Vote to skip the current song
                          (Bot commanders bypass voting)
    #{@prefix}undo                 - Removes the most recent item added to the queue
    #{@prefix}np                   - Now Playing
    #{@prefix}help                 - Shows this help
    #{@prefix}filters              - Shows information about filters
    #{@prefix}stats                - Technical stuff about the bot
    #{@prefix}ping                 - Pong!
    #{@prefix}seal                 - Sends seal pictures
    #{@prefix}sauce                - Sends a link to the current item's sauce

    Bot Commanders Only:
    #{@prefix}volume  <vol>        - Sets volume of the bot
    #{@prefix}shuffle              - Shuffles the queue
    #{@prefix}stop                 - Stops playback an clears the queue
    #{@prefix}clean                - Deletes messages sent by the bot (requires permission to do so)
    ```
    """
    msg.author.openDM().then (dm)=>
      dm.sendMessage reply
      msg.reply 'Check your DMs!' if msg.channel.guild_id
    

  filtersCommandFunction: (msg,args)=>
    reply = """
    **About Filters**

    FocaBot supports some basic audio effects and filters.

    For example:
    ```
    #{@prefix}play Noma - Brain Power | speed=1.5
    ```
    Will play Brain Power at 1.5x speed!

    You can also chain multiple filters in this way:
    ```
    #{@prefix}play Rick Hentai | speed=0.75 reverse lowpass=1000
    ```

    Here is a complete list of filters:

    **| speed**
    Changes the speed of the song. For example `| speed=0.75`

    **| tempo**
    Changes the speed of the song without altering the pitch. For example `| tempo=2`

    **| reverse**
    Reverses the song

    **| volume**
    (This filter is for Bot Commanders only, as it can be used for "ear rapes")
    Multiplies the volume of the song by the specified number. For example `| volume=2`

    **| lowpass**
    Applies a low pass filter. For example `| lowpass=500`

    **| highpass**
    Applies a high pass filter. For Example `| highpass=1000`

    **| bass**
    (This filter is for Bot Commanders only)
    Applies a bass boost filter. Use 20 for MAXIMUM bass boost *(not recommended)* `| bass=2`

    **| chorus**
    Applies a chorus filter.

    **| echo**
    Applies an echo filter

    **| flanger**
    A flanger effect. `| flanger=0.5`

    **| phaser**
    A phaser effect.

    **| time**
    Trims the song.
    For example `| time=0:15` will make the song start at 15 seconds.
    You can also specify a duration: `| time=0:15-30` will make the song start at 0:15 and last 30 seconds.

    **| nightcore** (Preset, same as speed=1.5)
    **| vaporwave** (Preset, same as speed=0.75)
    **| earrape** (Preset, same as volume=25)
    """
    msg.author.openDM().then (dm)=>
      dm.sendMessage reply
      msg.reply 'Check your DMs!' if msg.channel.guild_id

module.exports = HelpModule

class HelpModule extends BotModule
  init: =>
    {@prefix, @getGuildData} = @engine
    @registerCommand 'help', { allowDM: true }, @helpCommandFunction
    @registerCommand 'filters', { allowDM: true }, @filtersCommandFunction

  helpCommandFunction: (msg, args)=> @getGuildData(msg.guild).then (d)=>
    pfx = d.data.prefix or @prefix
    gstr = ""
    if msg.guild
      gstr = "\nPrefix for `#{msg.guild.name}`: #{pfx}"
    reply = """
    **#{@engine.name} #{@engine.version} (#{@engine.versionName})**
    Made by <@164588804362076160>
    #{gstr}
    
    This bot is not yet public, though you can send me a DM if you want it on your server.

    Changelog: https://gist.github.com/TheBITLINK/61f86a841f7d6fed896363d67ddd4d40

    Command List:
    ```
    Available to Everyone:
    #{pfx}play    <link/title> - Plays the requested song
    #{pfx}queue                - Shows the current song queue
    #{pfx}skip                 - Vote to skip the current song
                          (Bot commanders bypass voting)
    #{pfx}undo                 - Removes the most recent item added to the queue
    #{pfx}np                   - Now Playing
    #{pfx}help                 - Shows this help
    #{pfx}filters              - Shows information about filters
    #{pfx}stats                - Technical stuff about the bot
    #{pfx}ping                 - Pong!
    #{pfx}seal                 - Sends seal pictures
    #{pfx}sauce                - Sends a link to the current item's sauce
    #{pfx}|                    - Applies filters to the current song (see #{pfx}filters)
    #{pfx}img <query>          - Finds an image matching the query.
    #{pfx}rimg <query>         - Same as above, but finds a random image instead.
    #{pfx}imgn <query>         - Finds an image (with the adult filter disabled).
    #{pfx}rimgn <query>        - Finds a random image (with the adult filter disabled).
    #{pfx}+ <tag> <reply>      - Adds a new tag
    #{pfx}- <tag> [reply]      - Removes a tag
    #{pfx}! <tag>              - Displays the contents of the tag

    DJs Only:
    #{pfx}volume  <vol>        - Sets volume of the bot
    #{pfx}shuffle              - Shuffles the queue
    #{pfx}stop                 - Stops playback an clears the queue
    #{pfx}remove <position>    - Removes the song at the specified position
    #{pfx}swap <pos1> <pos2>   - Swaps the positions of the specified items
    #{pfx}seek <time>          - Seeks to the specified position

    Bot Commanders Only:
    #{pfx}clean                - Deletes messages sent by the bot (requires permission to do so)
    #{pfx}reset                - Resets FocaBot in your server (Temporary, read the changelog)
    #{pfx}config               - Configures the bot (run it to get more info)
    ```
    """
    msg.author.openDM().then (dm)=>
      dm.sendMessage reply
      msg.reply 'Check your DMs!' if msg.channel.guild_id
    

  filtersCommandFunction: (msg,args)=> @getGuildData(msg.guild).then (d)=>
    pfx = d.data.prefix or @prefix
    reply = """
    **About Filters**

    FocaBot supports some basic audio effects and filters.

    For example:
    ```
    #{pfx}play Noma - Brain Power | speed=1.5
    ```
    Will play Brain Power at 1.5x speed!

    You can also chain multiple filters in this way:
    ```
    #{pfx}play Rick Hentai | speed=0.75 reverse lowpass=1000
    ```

    ***DON'T EVER TRY TO STACK MORE THAN 3 FILTERS, OTHERWISE YOU MIGHT END WITH THIS ABOMINATION***
    https://youtu.be/Bg9fwP1vMv0

    Since FocaBot v0.4.9 you can also change filters while the song is playing:
    ```'| nightcore echo```
    You can only do this on songs requested by yourself if you are not a bot commander.
    Please note that not all filters are supported. Also, this might pause the song for a while, depending on the length.

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

    **| nofx**
    This is a dummy filter that prevents making changes to the filters while the song plays

    **| nightcore** (Preset, same as speed=1.5)
    **| chipmunk** (Preset, same as speed=2)
    **| vaporwave** (Preset, same as speed=0.75)
    **| earrape** (Preset, same as volume=25)
    """
    msg.author.openDM().then (dm)=>
      dm.sendMessage reply
      msg.reply 'Check your DMs!' if msg.channel.guild_id

module.exports = HelpModule

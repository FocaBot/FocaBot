class ConfigCommands
  constructor: (@module)->
    @params = {
      prefix:
        type: String
        min: 1
        max: 5
        def: Core.settings.prefix
      autoDel:
        type: Boolean
        def: true
      allowNSFW:
        type: Boolean
        def: false
      voteSkip:
        type: Boolean
        def: true
      restrict:
        type: Boolean
        def: false
      allowWaifus:
        type: Boolean
        def: true
      allowTags:
        type: Boolean
        def: true
      allowImages:
        type: Boolean
        def: true
      greet:
        type: String
        min: 1
        def: 'off'
      farewell:
        type: String
        min: 1
        def: 'off'
      maxSongLength:
        type: Number
        integer: true
        min: 15
        max: 21600
        def: 1800
      dynamicNick:
        type: Boolean
        def: false
      maxItems:
        type: Number
        integer: true
        min: 0
        def: 0
      allowRNG:
        type: Boolean
        def: true
      raffleMention:
        type: Boolean
        def: false
    }

    @module.registerCommand 'config', { adminOnly: true, argSeparator: ' ' }, (msg,args,d)=>
      sendHelp = (r)->
        msg.reply '', false, {
          author:
            name: r
          title: '[Click for help]'
          color: 0xFF3300
          url: 'https://focabot.thebit.link/manual#configuration'
        }
      return msg.reply """
      Usage:
      \`\`\`
      #{Core.settings.prefix}config <parameter> [value]
      \`\`\`
      """ unless args[0]
      return sendHelp 'Invalid Parameter.' unless @params[args[0]]
      # Send current value if not asked for new value
      return msg.reply '', false, {
        title: msg.guild.name
        fields: [
          { name: 'Parameter', value: args[0], inline: true }
          {
            name: 'Current Value'
            value: d.data[args[0]] || @params[args[0]].def
            inline: true
          }
        ]
      } unless args[1]
      param = @params[args[0]]
      value = args.slice(1).join(' ')
      switch param.type
        when String
          return sendHelp 'Value is too short' if param.min and param.min > value.length
          return sendHelp 'Value is too long' if param.max and param.max < value.length
          d.data[args[0]] = value
        when Boolean
          switch value
            when 'true', 'on', 'yes', '1', 'y'
              d.data[args[0]] = true
            when 'false', 'off', 'no', '0', 'n'
              d.data[args[0]] = false
            else return sendHelp 'Invalid value. Please use either `yes` or `no`.'
        when Number
          value = parseFloat(value)
          value = parseInt(value) if param.integer
          return sendHelp 'Value is not a number.' if not isFinite(value)
          return sendHelp 'Value is too high' if param.max and value > param.max
          return sendHelp 'Value is too low' if param.min and value < param.min
          d.data[args[0]] = value
      # Save the changes
      await d.saveData()
      msg.reply 'Setting saved!', false, {
        title: msg.guild.name
        color: 0x00AAFF
        fields: [
          { name: 'Parameter', value: args[0], inline: true }
          { name: 'Current Value', value: d.data[args[0]], inline: true }
        ]
      }

module.exports = ConfigCommands

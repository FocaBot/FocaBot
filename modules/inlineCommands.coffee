class InlineCommands extends BotModule
  init: ->
    @defaultDisabled = true

    @registerEvent 'discord.message', (message)=>
      if message.content.match(/{{(.*)}}/)
        Core.commands.processMessage(message, message.content.match(/{{(.*)}}/)[1])

module.exports = InlineCommands

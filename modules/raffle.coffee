Chance = require 'chance'

class Raffle extends BotModule
  init: =>
    @chance = new Chance()

    # Starts a new raffle
    @registerCommand 'rafflestart', { adminOnly: true }, (msg, args, d)=>
      prefix = d.data.prefix or Core.settings.prefix
      try msg.delete() if d.data.autoDel

      raffle = await Core.data.get("Raffle:#{msg.guild.id}")
      if raffle
        return msg.reply """
        A previous raffle is still open. (#{raffle.participants.length} participants)
        Close it with `#{prefix}raffleClose` before starting a new one.
        """
      await Core.data.set("Raffle:#{msg.guild.id}", {
        type: args or 'single'
        participants: [],
        winners: []
      })

      msg.channel.sendMessage """
      #{if d.data.raffleMention then '@everyone ' else ''}\
      A new raffle has just started! To join, use the `#{prefix}raffleJoin` command.
      """

    # Joins an existing raffle
    @registerCommand 'rafflejoin', (msg, args, d)=>
      try msg.delete() if d.data.autoDel

      raffle = await Core.data.get("Raffle:#{msg.guild.id}")
      return msg.reply("There isn't any raffle going on right now.") unless raffle
      if msg.member.id in raffle.participants or msg.member.id in raffle.winners
        return msg.reply('You already joined this raffle.')
      # Save
      raffle.participants.push(msg.member.id)
      await Core.data.set("Raffle:#{msg.guild.id}", raffle)
      # Save stats
      uStats = (await Core.data.get("RaffleStats:#{msg.member.id}")) or { total: [], won: [] }
      uStats.total.push(msg.guild.id)
      await Core.data.set("RaffleStats:#{msg.member.id}", uStats)
      
      msg.channel.sendMessage """
      #{msg.member.mention} joined the raffle! (#{raffle.participants.length} participants).
      """

    # Pick winners.
    @registerCommand 'rafflepick', { adminOnly: true }, (msg, args, d)=>
      try msg.delete() if d.data.autoDel
      raffle = await Core.data.get("Raffle:#{msg.guild.id}")
      return msg.reply("There isn't any raffle going on right now.") unless raffle
      # Filter out participants
      participants = raffle.participants
      unless raffle.type is 'multi'
        participants = raffle.participants.filter((p) => p not in raffle.winners)
      return msg.reply 'No participants left.' unless participants.length
      winner = @chance.pickone(participants)
      raffle.winners.push(winner)
      # Save
      await Core.data.set("Raffle:#{msg.guild.id}", raffle)
      u = Core.bot.Users.get(winner).memberOf(msg.guild)
      # Save stats
      if raffle.winners.filter((w)=> w is winner).length is 1
        uStats = (await Core.data.get("RaffleStats:#{winner}")) or { total: [], won: [] }
        uStats.won.push(msg.guild.id)
        await Core.data.set("RaffleStats:#{winner}", uStats)

      msg.channel.sendMessage """
      #{u.mention} wins this raffle!
      """

    # Close raffle.
    @registerCommand 'raffleclose', { adminOnly: true }, (msg, args, d)=>
      try msg.delete() if d.data.autoDel
      raffle = await Core.data.get("Raffle:#{msg.guild.id}")
      return msg.reply("There isn't any raffle going on right now.") unless raffle
      # Delete
      await Core.data.del("Raffle:#{msg.guild.id}")
      m = """
      #{if d.data.raffleMention then '@everyone ' else ''}\
      The raffle is now closed.

      **__Overview__**:
      **#{raffle.participants.length}** total participants.
      **#{raffle.winners.length}** total winners.
      """
      if raffle.winners.length > 0
        m += '\n\n**__Placements__**:'
        for winner, i in raffle.winners
          m += "\n**#{i + 1}**. #{Core.bot.Users.get(winner).memberOf(msg.guild).mention}"
      
      msg.channel.sendMessage m

    # Raffle stats for an user
    @registerCommand 'rafflestats', (msg, args, d)=>
      u = msg.mentions[0] or msg.member
      uStats = (await Core.data.get("RaffleStats:#{u.id}")) or { total: [], won: [] }
      msg.channel.sendMessage '', false, {
        title: "Raffle stats for #{u.name or u.username}"
        thumbnail:
          url: u.staticAvatarURL
        fields: [
          {
            name: msg.guild.name
            value: """

            **Participated**: #{uStats.total.filter((i) => i is msg.guild.id).length}
            **Won**: #{uStats.won.filter((i) => i is msg.guild.id).length}
            """
            inline: true
          },
          {
            name: 'Overall'
            value: """

            **Participated**: #{uStats.total.length}
            **Won**: #{uStats.won.length}
            """
            inline: true
          }
        ]
      }

module.exports = Raffle

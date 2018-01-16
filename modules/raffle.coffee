Chance = require 'chance'

class Raffle extends BotModule
  init: ->
    chance = new Chance()
    @registerParameter 'raffleMention', { type: Boolean, def: false }

    # Starts a new raffle
    @registerCommand 'rafflestart', { adminOnly: true }, ({ msg, args, s, l })=>
      try msg.delete() if s.autoDel

      raffle = await Core.data.get("Raffle:#{msg.guild.id}")
      if raffle then return msg.reply l.gen(
        l.raffle.previousRaffleOpen, raffle.participants.length, "#{s.prefix}raffleClose"
      )

      await Core.data.set("Raffle:#{msg.guild.id}", {
        type: args or 'single'
        participants: [],
        winners: []
      })

      msg.channel.send """
      #{if s.raffleMention then '@everyone ' else ''}\
      #{l.gen(l.raffle.raffleStarted, s.prefix + "raffleJoin")}
      """

    # Joins an existing raffle
    @registerCommand 'rafflejoin', ({ msg, args, s, l })=>
      try msg.delete() if s.autoDel

      raffle = await Core.data.get("Raffle:#{msg.guild.id}")
      return msg.reply(l.raffle.noRaffle) unless raffle
      if msg.member.id in raffle.participants or msg.member.id in raffle.winners
        return msg.reply(l.raffle.alreadyJoined)
      # Save
      raffle.participants.push(msg.member.id)
      await Core.data.set("Raffle:#{msg.guild.id}", raffle)
      # Save stats
      uStats = (await Core.data.get("RaffleStats:#{msg.member.id}")) or { total: [], won: [] }
      uStats.total.push(msg.guild.id)
      await Core.data.set("RaffleStats:#{msg.member.id}", uStats)
      
      msg.channel.send l.gen(l.raffle.joined, msg.member, raffle.participants.length)

    # Pick winners.
    @registerCommand 'rafflepick', { adminOnly: true }, ({ msg, args, s, l })=>
      try msg.delete() if s.autoDel

      raffle = await Core.data.get("Raffle:#{msg.guild.id}")
      return msg.reply(l.raffle.noRaffle) unless raffle

      # Filter out participants
      participants = raffle.participants
      unless raffle.type is 'multi'
        participants = raffle.participants.filter((p) => p not in raffle.winners)
      return msg.reply l.raffle.noParticipantsLeft unless participants.length
      winner = chance.pickone(participants)
      raffle.winners.push(winner)
      # Save
      await Core.data.set("Raffle:#{msg.guild.id}", raffle)
      u = msg.guild.members.find('id', winner)
      # Save stats
      if raffle.winners.filter((w)=> w is winner).length is 1
        uStats = (await Core.data.get("RaffleStats:#{winner}")) or { total: [], won: [] }
        uStats.won.push(msg.guild.id)
        await Core.data.set("RaffleStats:#{winner}", uStats)

      msg.channel.send l.gen(l.raffle.winner, u)

    # Close raffle.
    @registerCommand 'raffleclose', { adminOnly: true }, ({ msg, args, s, l })=>
      try msg.delete() if s.autoDel

      raffle = await Core.data.get("Raffle:#{msg.guild.id}")
      return msg.reply(l.raffle.noRaffle) unless raffle
      # Delete
      await Core.data.del("Raffle:#{msg.guild.id}")
      m = """
      #{if s.raffleMention then '@everyone ' else ''}\
      #{l.raffle.closed}

      #{l.raffle.overview}
      #{l.gen(l.raffle.totalParticipants, raffle.participants.length)}
      #{l.gen(l.raffle.totalWinners, raffle.winners.length)}
      """
      if raffle.winners.length > 0
        m += "\n\n#{l.raffle.placements}"
        for winner, i in raffle.winners
          m += "\n**#{i + 1}**. #{msg.guild.members.find('id', winner)}"
      
      msg.channel.send m

    # Raffle stats for an user
    @registerCommand 'rafflestats', ({ msg, args, l })=>
      u = msg.mentions.members.first() or msg.member
      uStats = (await Core.data.get("RaffleStats:#{u.id}")) or { total: [], won: [] }
      msg.channel.send '', embed: {
        title: l.gen(l.raffle.raffleStats, u.displayName)
        thumbnail:
          url: u.user.displayAvatarURL
        # coffeelint: disable=max_line_length
        fields: [
          {
            name: msg.guild.name
            value: """

            #{l.gen(l.raffle.participated, uStats.total.filter((i) => i is msg.guild.id).length)}
            #{l.gen(l.raffle.won, uStats.won.filter((i) => i is msg.guild.id).length)}
            """
            inline: true
          },
          {
            name: l.raffle.overall
            value: """

            #{l.gen(l.raffle.participated, uStats.total.length)}
            #{l.gen(l.raffle.won, uStats.won.length)}
            """
            inline: true
          }
        ]
        # coffeelint: enable=max_line_length
      }

module.exports = Raffle

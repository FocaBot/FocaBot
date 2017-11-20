osu = require 'node-osu'
osuApi = new osu.Api(process.env.OSU_KEY)

class OsuModule extends BotModule
  init: =>
    @registerCommand 'osu', {
      allowDM: true
      aliases: ['taiko', 'ctb', 'mania']
      includeCommandNameInArgs: true
    }, @osuCheck

  osuCheck: ({msg, args, s, l})=>
    modes = {
      'osu': 0
      'taiko': 1
      'ctb': 2
      'mania': 3
    }

    try
      user = await osuApi.getUser
                     u: args[1]
                     m: modes[args[0]]
    catch e
      return msg.reply l.generic.noResults
    msg.reply '', embed: {
      url: "https://osu.ppy.sh/users/#{user.id}"
      color: 0x00AAFF
      author: {
        name: l.gen(l.osu.profile, user.name)
        icon_url: "https://lemmmy.pw/osusig/img/#{args[0]}.png"
      }
      thumbnail:
        url: "https://a.ppy.sh/#{user.id}"
      fields: [
        {
          name: l.gen(l.osu.performance, user.pp.raw, user.pp.rank, user.country, user.pp.countryRank),
          value: l.gen(l.osu.stats, user.level, user.accuracyFormatted, user.counts.plays, user.scores.ranked, user.scores.total, user.counts.SS, user.counts.S, user.counts.A)
        }
      ]
      footer:
        icon_url: 'https://w.ppy.sh/c/c9/Logo.png'
        text: l.osu.official
    }

module.exports = OsuModule

osu = require 'node-osu'
osuApi = new osu.Api(process.env.OSU_KEY)

class OsuModule extends BotModule
  init: ->
    @registerCommand 'osu', {
      allowDM: true
      aliases: ['taiko', 'ctb', 'mania']
      includeCommandNameInArgs: true
    }, @osuCheck

  osuCheck: (msg, args, d)->
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
      return msg.reply 'User not found.'
    msg.reply '', false, {
      url: "https://osu.ppy.sh/users/#{user.id}"
      color: 0x00AAFF
      author: {
        name: "osu! Profile for #{user.name}"
        icon_url: "https://lemmmy.pw/osusig/img/#{args[0]}.png"
      }
      thumbnail:
        url: "https://a.ppy.sh/#{user.id}"
      fields: [
        {
          name: "Performance: #{user.pp.raw}pp (\##{user.pp.rank}, #{user.country}\##{user.pp.countryRank})",
          value: """
           ▸ **Level**: #{user.level}
           ▸ **Hit accuracy**: #{user.accuracyFormatted}
           ▸ **Play count**: #{user.counts.plays}
           ▸ **Ranked score**: #{user.scores.ranked}
           ▸ **Total score**: #{user.scores.total}
           ▸ **SS**: #{user.counts.SS} **S**: #{user.counts.S} **A**: #{user.counts.A}
          """
        }
      ]
      footer:
        icon_url: 'https://w.ppy.sh/c/c9/Logo.png'
        text: 'On osu! official server'
    }

module.exports = OsuModule

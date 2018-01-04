class BlacklistSC
  init: ->
    Core.properties.blacklist = (await Core.data.get('Blacklist')) or []
    # Auto Update
    Core.data.subscribe('Blacklist', (data) => Core.properties.blacklist = data)

  add: (user)->
    u = user
    u = user.id if user.id
    unless u in Core.properties.blacklist
      Core.properties.blacklist.push(u)
      # Save
      await Core.data.set('Blacklist', Core.properties.blacklist)

  remove: (user)->
    u = user
    u = user.id if user.id
    if u in Core.properties.blacklist
      Core.properties.blacklist.splice(Core.properties.blacklist.indexOf(u), 1)
      # Save
      await Core.data.set('Blacklist', Core.properties.blacklist)

module.exports = BlacklistSC

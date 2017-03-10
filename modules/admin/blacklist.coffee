class BlacklistSC
  init: =>
    Core.settings.blacklist = (await Core.data.get('Blacklist')) or []
    # Auto Update
    Core.data.subscribe('blacklist')
    Core.data.on 'message', (channel, data)=>
      return unless channel is 'blacklist'
      Core.settings.blacklist = data

  add: (user)=>
    u = user
    u = user.id if user.id
    unless u in Core.settings.blacklist
      Core.settings.blacklist.push(u)
      # Save
      await Core.data.set('Blacklist', Core.settings.blacklist)
      # Notify the other shards
      Core.data.publish('blacklist', Core.settings.blacklist)

  remove: (user)=>
    u = user
    u = user.id if user.id
    if u in @doc.users
      Core.settings.blacklist.splice(Core.settings.blacklist.indexOf(u), 1)
      # Save
      await Core.data.set('Blacklist', Core.settings.blacklist)
      # Notify the other shards
      Core.data.publish('blacklist', Core.settings.blacklist)

module.exports = BlacklistSC

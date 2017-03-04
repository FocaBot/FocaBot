{ type } = Core.db

Blacklist = Core.db.createModel 'Blacklist', {
  id: type.string()
  users: [type.string()]
}

class BlacklistSC
  init: =>
    @doc = await Blacklist.filter({}).run()[0]
    @doc = new Blacklist(users: []) unless @doc?
    Core.settings.blacklist = @doc.users
    # Auto Update
    @feed = await Blacklist.changes()
    @feed.each (error, d)=> Core.settings.blacklist = d.users

  add: (user)=>
    u = user
    u = user.id if user.id
    unless u in @doc.users
      @doc.users.push(u)
      await @doc.save()

  remove: (user)=>
    u = user
    u = user.id if user.id
    if u in @doc.users
      @doc.users.splice(@doc.users.indexOf(u), 1)
      await @doc.save()

module.exports = BlacklistSC

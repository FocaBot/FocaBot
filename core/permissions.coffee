class BotPermissionManager
  constructor: (@engine)->
    {@bot} = @engine
    {@owner, @admins, @adminRoles, @djRoles} = @engine.settings

  isAdmin: (user, guild, globalOnly)=>
    return true if user.id in @admins or user.id in @owner
    if not globalOnly
      return false if not guild?
      return true if user.id is guild.owner_id
      member = user.memberOf(guild)
      return false if not member?
      member.roles.filter (item)=> item.name in @adminRoles
      .length > 0
    else
      false
    
  isDJ: (user, guild)=>
    return true if @isAdmin user, guild
    member = user.memberOf(guild)
    return false if not member?
    member.roles.filter (item)=> item.name in @djRoles
    .length > 0
    
  isOwner: (user)=> user.id in @owner

module.exports = BotPermissionManager
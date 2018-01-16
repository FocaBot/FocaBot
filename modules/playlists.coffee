class Playlists extends BotModule
  init: ->
    try
      @player = Core.modules.loaded['player']
    catch e
      throw new Error 'This module must be loaded before the player module!!'
    
    @registerCommand 'playlist', { argSeparator: ' ', aliases: ['pl'] }, ({ msg, args, l })=>
      player = await @player.getForGuild(msg.guild)
      return l.generic.invalidArgs if not args[0]

      switch args[0]
        when 'save', 's', 'export', 'e'
          # Check if there's a playlist with the same name
          return msg.reply l.generic.invalidArgs if not args[1]
          playlist = await Core.data.get("Playlist:#{args[1]}")
          return msg.reply l.player.playlistExists if playlist
          # Save current queue as playlist
          return msg.reply l.player.notPlaying if not player.queue.nowPlaying?
          items = genPlaylistItems(player)
          await Core.data.set("Playlist:#{args[1]}", {
            owner: msg.author.id
            collaborators: []
            items
          })
          msg.reply l.player.playlistSaved
        when 'load', 'l', 'play', 'p', 'add', 'a', 'import', 'i'
          # Fetch the playlist
          return msg.reply l.generic.invalidArgs if not args[1]
          playlist = await Core.data.get("Playlist:#{args[1]}")
          return msg.reply l.player.playlistNotFound unless playlist
          # Restore playlist items
          # TODO: Restore filters as well
          Core.commands.run('play', msg, playlist.items.map((i)=> i.url).join('\n'))
        when 'update', 'u'
          # Fetch the playlist
          return msg.reply l.generic.invalidArgs if not args[1]
          playlist = await Core.data.get("Playlist:#{args[1]}")
          return msg.reply l.player.playlistNotFound unless playlist
          # Check if the user is allowed to update
          if playlist.owner isnt msg.author.id and msg.author.id not in playlist.collaborators
            return msg.reply l.player.playlistForbidden
          # Update the playlist
          if not player.queue.nowPlaying?
            return l.player.notPlaying
          playlist.items = genPlaylistItems(player)
          await Core.data.set("Playlist:#{args[1]}", playlist)
          msg.reply l.player.playlistUpdated
        when 'collaborators', 'collaborator', 'collab', 'c'
          # Fetch the playlist
          return msg.reply l.generic.invalidArgs if not args[1] or not args[2]
          playlist = await Core.data.get("Playlist:#{args[2]}")
          return msg.reply l.player.playlistNotFound unless playlist
          # Check if the user is allowed to update
          if playlist.owner isnt msg.author.id
            return msg.reply l.player.playlistForbidden
          switch args[2]
            when 'add', 'a'
              u = msg.mentions.users.first()
              return msg.reply l.generic.invalidArgs unless u
              if playlist.collaborators.indexOf(u.id) < 0
                playlist.collaborators.push(u.id)
                await Core.data.set("Playlist:#{args[2]}", playlist)
                msg.reply l.player.playlistUpdated
            when 'remove', 'r'
              u = msg.mentions.users.first()
              return msg.reply l.generic.invalidArgs unless u
              if playlist.collaborators.indexOf(u.id) >= 0
                playlist.collaborators.splice(playlist.collaborators.indexOf(u.id), 1)
                await Core.data.set("Playlist:#{args[2]}", playlist)
                msg.reply l.player.playlistUpdated
            else
              return msg.reply l.generic.invalidArgs
        when 'owner', 'o'
          # Fetch the playlist
          return msg.reply l.generic.invalidArgs if not args[1]
          playlist = await Core.data.get("Playlist:#{args[1]}")
          return msg.reply l.player.playlistNotFound unless playlist
          # Check if the user is allowed to update
          if playlist.owner isnt msg.author.id
            return msg.reply l.player.playlistForbidden
          u = msg.mentions.users.first()
          return msg.reply l.generic.invalidArgs unless u
          playlist.owner = u.id
          await Core.data.set("Playlist:#{args[1]}", playlist)
          msg.reply l.player.playlistUpdated
        when 'delete', 'del', 'd'
          # Fetch the playlist
          return msg.reply l.generic.invalidArgs if not args[1]
          playlist = await Core.data.get("Playlist:#{args[1]}")
          return msg.reply l.player.playlistNotFound unless playlist
          # Check if the user is allowed to delete
          if playlist.owner isnt msg.author.id
            return msg.reply l.player.playlistForbidden
          await Core.data.del("Playlist:#{args[1]}")
          msg.reply l.player.playlistDeleted
        else
          return msg.reply l.generic.invalidArgs
  
  genPlaylistItems = (player)->
    [player.queue.nowPlaying].concat(player.queue.items).map (itm)=> {
      title: itm.title,
      duration: itm.duration,
      filters: itm.filters.map (filter)=> "#{filter.name}=#{filter.param}"
      url: itm.sauce
    }

module.exports = Playlists

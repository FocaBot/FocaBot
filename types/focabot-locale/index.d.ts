/**
 * FocaBot Locale TypeScript Definition
 * Generated automatically from en_US/strings.yml on 2018-08-15T14:28:10.159Z
 */
import { Locale } from 'azarasi/lib/locales'

declare module 'azarasi/lib/locales' {
  interface Locale {
    generic : {
      /**
       * Something went wrong.
       */
      error : string
      /**
       * Invalid arguments provided.
       */
      invalidArgs : string
      /**
       * No results.
       */
      noResults : string
      /**
       * Success!
       */
      success : string
      /**
       * Saved!
       */
      saved : string
      /**
       * \[click for sauce\]
       */
      sauceBtn : string
      /**
       * \[click for help\]
       */
      helpBtn : string
      /**
       * \[donate\]
       */
      donateBtn : string
      /**
       * Usage:
       */
      commandUsage : string
      /**
       * This command has a cooldown, try again in a few seconds...
       */
      cooldown : string
      /**
       * You are not allowed to use this command.
       */
      forbidden : string
      /**
       * You need the `{1}` role.
       */
      needRole : string
    }
    player : {
      /**
       * You must be in a voice channel.
       */
      noVoice : string
      /**
       * You must be in the same voice channel the bot is in.
       */
      noSameVoice : string
      /**
       * You are not allowed to use the bot in this voice channel.
       */
      notAllowed : string
      /**
       * You have exceeded the limit of items in queue for this server.
       */
      queueLimit : string
      /**
       * Invalid start time.
       */
      invalidStart : string
      /**
       * Only DJs can add playlists.
       */
      playlistNoDJ : string
      /**
       * Nothing's being played in this server.
       */
      notPlaying : string
      /**
       * **{1}** skipped the current song.
       */
      skip : string
      /**
       * You are not allowed to skip songs.
       */
      noSkipAllowed : string
      /**
       * **{1}** voted to skip the current song ({2}/{3})
       */
      voteSkip : string
      /**
       * Did you really try to skip this song ***again***?
       */
      alreadyVoted : string
      /**
       * Skipping current song ~~with the power of democracy~~...
       */
      voteSkipSuccess : string
      /**
       * Queue cleared.
       */
      queueCleared : string
      /**
       * The queue is empty.
       */
      queueEmpty : string
      /**
       * Sorry, no sauce for the current item...
       */
      noSauce : string
      /**
       * Here's the sauce of the current item: {1}
       */
      sauce : string
      /**
       * Can't find the specified item in the queue.
       */
      noSuchItem : string
      /**
       * You can only remove your own items from the queue.
       */
      onlyRemoveOwn : string
      /**
       * Only DJs can change the volume.
       */
      noVolumeChange : string
      /**
       * The queue is now frozen. No changes can be made to the playlist unless you unfreeze it.
       */
      queueFrozen : string
      /**
       * The queue is no longer frozen.
       */
      queueUnfrozen : string
      /**
       * Couldn't join voice channel. Skipping...
       */
      cantJoin : string
      /**
       * Can't pause (restrictive filters).
       */
      noRestrictivePause : string
      /**
       * Can't pause streams.
       */
      noStreamPause : string
      /**
       * Can't seek (restrictive filters).
       */
      noRestrictiveSeek : string
      /**
       * Can't seek (livestream).
       */
      noStreamSeek : string
      /**
       * Invalid position.
       */
      invalidSeek : string
      /**
       * The current song has one or more restrictive filters.
       */
      restrictiveFilters : string
      /**
       * Can't change filters (livestream).
       */
      livestreamFilters : string
      /**
       * You can't add restrictive filters during playback.
       */
      restrictiveFiltersAdd : string
      /**
       * Can't change volume (livestream).
       */
      noStreamVolume : string
      /**
       * The requested video is too long
       */
      tooLong : string
      /**
       * A filter reported errors:
       */
      filterErrors : string
      /**
       * Removed **{1}** items from the queue!
       */
      multiRemove : string
      /**
       * There's another playlist being loaded, please wait.
       */
      playlistAlreadyLoading : string
      /**
       * No query specified.
       */
      noQuery : string
      /**
       * Playlist saved!
       */
      playlistSaved : string
      /**
       * Playlist updated!
       */
      playlistUpdated : string
      /**
       * No such playlist.
       */
      playlistNotFound : string
      /**
       * A playlist with that ID already exists.
       */
      playlistExists : string
      /**
       * You don't have permission to update that playlist.
       */
      playlistForbidden : string
      /**
       * Playlist deleted!
       */
      playlistDeleted : string
      /**
       * Couldn't take screenshot
       */
      screenshotError : string
      hud : {
        /**
         * Now playing in `{1}`:
         */
        nowPlaying : string
        /**
         * Removed from the queue:
         */
        removed : string
        /**
         * Added to the queue:
         */
        added : string
        /**
         * Current Volume: **{1}**.
         */
        currentVolume : string
        /**
         * {1} set global volume to **{2}**.
         */
        volumeSet : string
        /**
         * Requested by {1}
         */
        requestedBy : string
        /**
         * Removed by {1}
         */
        removedBy : string
        /**
         * **__Radio stream__**
         */
        radioStream : string
        /**
         * **Track Title**: `{1}`
         */
        radioTrack : string
        /**
         * **Next Track**: `{1}`
         */
        radioNext : string
        /**
         * {1} swapped some items:
         */
        swap : string
        /**
         * {1} moved the following item:
         */
        move : string
        /**
         * Length:
         */
        length : string
        /**
         * Position in queue:
         */
        position : string
        /**
         * Filters:
         */
        filters : string
        /**
         * Start At:
         */
        startTime : string
        /**
         * Estimated time for playback:
         */
        estimated : string
        /**
         * Loading playlist...
         */
        playlistLoading : string
        /**
         * **{1}** items loaded so far. (Use {2} to cancel)
         */
        playlistCount : string
        /**
         * **{1}** items.
         */
        playlistFinalCount : string
        /**
         * ✅ Playlist Added!
         */
        playlistLoaded : string
        /**
         * (Playlist Cancelled)
         */
        playlistCancelled : string
        /**
         * Page {1} does not exist.
         */
        noSuchPage : string
        /**
         * Up next:
         */
        upNext : string
        /**
         * {1} total items ({2}). Page {3}/{4}
         */
        queueFooter : string
        /**
         * Use {1} to see the next page.
         */
        queueNext : string
        /**
         * 🔁 Loop Mode Enabled! [Playlist]
         */
        playlistLoopMode : string
        /**
         * 🔂 Loop Mode Enabled! [Song]
         */
        songLoopMode : string
        /**
         * Searching...
         */
        searching : string
        /**
         * Results:
         */
        results : string
      }
    }
    admin : {
      /**
       * Language set to {1}!
       */
      languageChanged : string
      /**
       * Could not delete messages. Check if the bot has permission.
       */
      cantDelete : string
      /**
       * FocaBot is restarting...
       */
      restarting : string
      /**
       * FocaBot is updating...
       */
      updating : string
      /**
       * Downloading latest version of youtube-dl...
       */
      ytdlUpdate : string
      /**
       * Successfully downloaded youtube-dl {1}!
       */
      ytdlUpdated : string
      /**
       * Could not download latest version of youtube-dl, please try again.
       */
      ytdlUpdateError : string
      /**
       * Nickname changed successfully!
       */
      nickChanged : string
      /**
       * Avatar changed successfully!
       */
      avatarChanged : string
      /**
       * Username changed successfully!
       */
      usernameChanged : string
      /**
       * No user specified.
       */
      noUserSpecified : string
      /**
       * Blacklisted **{1}**.
       */
      blacklistAdd : string
      /**
       * Removed **{1}** from the blacklist.
       */
      blacklistRemove : string
      /**
       * No such module.
       */
      noSuchModule : string
      /**
       * No such command.
       */
      noSuchCommand : string
      /**
       * Permissions Updated!
       */
      permissionsUpdated : string
      /**
       * Invalid permission level.
       */
      invalidLevel : string
      /**
       * Current settings for {1}:
       */
      currentSettings : string
      /**
       * Current permission level for {1}:
       */
      currentPermissionLevel : string
    }
    config : {
      /**
       * Parameter:
       */
      parameter : string
      /**
       * Value:
       */
      value : string
      /**
       * No parameter specified.
       */
      noParameter : string
      /**
       * Invalid parameter specified.
       */
      invalidParameter : string
      /**
       * Invalid value specified.
       */
      invalidValue : string
    }
    danbooru : {
      /**
       * Invalid safebooru tag
       */
      invalidTag : string
      /**
       * Run the {1} command first!
       */
      noWaifu : string
    }
    help : {
      /**
       * Help links:
       */
      links : string
      /**
       * Prefix for {1}:
       */
      prefix : string
      /**
       * Commands
       */
      commands : string
      /**
       * Filters
       */
      filters : string
      /**
       * Manual
       */
      manual : string
      /**
       * Donate
       */
      donate : string
    }
    image : {
      /**
       * Daily limit exceeded for this command.
       */
      dailyLimit : string
    }
    poll : {
      /**
       * Too many answers!!
       */
      tooManyAnswers : string
      /**
       * You need to specify at least 2 answers.
       */
      notEnoughAnswers : string
      /**
       * {1} started a poll:
       */
      pollStarted : string
    }
    raffle : {
      /**
       * A previous raffle is still open. ({1} participants).
       * Close it with `{2}` before starting a new one.
       */
      previousRaffleOpen : string
      /**
       * A new raffle has just started! To join, use the `{1}` command.
       */
      raffleStarted : string
      /**
       * There isn't any raffle going on right now.
       */
      noRaffle : string
      /**
       * You already joined this raffle.
       */
      alreadyJoined : string
      /**
       * {1} joined the raffle! ({2} participants).
       */
      joined : string
      /**
       * No participants left.
       */
      noParticipantsLeft : string
      /**
       * {1} wins this raffle!
       */
      winner : string
      /**
       * The raffle is now closed.
       */
      closed : string
      /**
       * **__Raffle Overview__**:
       */
      overview : string
      /**
       * **{1}** total participants.
       */
      totalParticipants : string
      /**
       * **{1}** total winners.
       */
      totalWinners : string
      /**
       * **__Raffle Placements__**:
       */
      placements : string
      /**
       * Raffle stats for {1}
       */
      raffleStats : string
      /**
       * **Participated**: {1}
       */
      participated : string
      /**
       * **Won**: {1}
       */
      won : string
      /**
       * Overall
       */
      overall : string
    }
    rng : {
      /**
       * {1} 🎲 rolls `{2}`.
       */
      roll : string
      /**
       * **Total**: __{1}__.
       */
      total : string
      /**
       * Not enough items to choose from. Remember to use `;` to separate them.
       */
      notEnoughItems : string
      /**
       * I choose {1}.
       */
      choice : string
      "8ball" : string[]
      /**
       * I'd give {1} a {2}/10.
       */
      rate : string
    }
    tags : {
      /**
       * Tag saved!
       */
      added : string
      /**
       * Deleted {1} tags!
       */
      deleted : string
    }
    osu : {
      /**
       * osu! Profile for {1}
       */
      profile : string
      /**
       * Performance: {1}pp (#{2}, {3}#{4})
       */
      performance : string
      /**
       * ▸ **Level**: {1}
       * ▸ **Accuracy**: {2}
       * ▸ **Play count**: {3}
       * ▸ **Ranked score**: {4}
       * ▸ **Total score**: {5}
       * ▸ **SS**: {6} **S**: {7} **A**: {8}
       */
      stats : string
      /**
       * in osu! official server
       */
      official : string
    }
    announcements : {
      /**
       * This is a global announcement. You can disable them by running {1}.
       */
      footer : string
    }
    lyrics : {
      /**
       * Searching lyrics for {1}...
       */
      searching : string
      /**
       * {1} lyrics:
       */
      title : string
      /**
       * \[More at Genius.com\]
       */
      more : string
    }
    math : {
      /**
       * Input:
       */
      input : string
      /**
       * Result:
       */
      result : string
    }
  }
}

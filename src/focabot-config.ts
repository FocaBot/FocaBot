/**
 * FocaBot configuration file (focabot.yml)
 */
export interface FocaBotConfig {
  /** Core bot settings */
  bot : {
    /** Bot Token */
    token : string
    /** Command prefix */
    prefix : string
    /** Bot Owners (User IDs) */
    owners : string[]
    /** Global Admins (User IDs) */
    globalAdmins : string[]
    /** Default locale */
    locale : string
    /** Debug mode */
    debug : boolean
  }
  /** Modules to load at startup */
  modules : string[]
  /** Role settings */
  roles : {
    /** Roles with "admin" level access */
    admin : string[]
    /** Roles with "dj" level access */
    dj : string[]
  }
  /** Data Store settings */
  data : {
    /** Data store backend */
    backend : 'memory' | 'gun' | 'redis'
    /** Settings for Redis backend */
    redis : {
      /** Redis server URL */
      server : string
    }
    /** Settings for Gun backend (DEPRECATED) */
    gun : {
      /** Database path */
      path : string
      /** Database port */
      port : number
    }
    /** Settings for CouchDB backend */
    couchdb : {
      /** Server URL */
      server : string
      /** Database Name */
      dbName : string
    }
  }
  /** Player module settings */
  player : {
    /** Audio player backend */
    backend : 'ffmpeg' | 'focastreamer'
    /** Settings for the FFMPEG backend */
    ffmpeg : {
      /** ffmpeg binary path (absolute) */
      bin? : string
      /** ffprobe binary path (absolute) */
      probeBin? : string
    }
    /** Settings for the FocaStreamer backend */
    focastreamer : {
      /** Binary path (absolute) */
      bin: string
    }
  }
  /** API keys */
  apiKeys : {
    /** Google API */
    google : {
      /** Google API key */
      apiKey : string
      /** Google CSE id */
      cx : string
    }
    /** Imgur client key */
    imgur : string
    /** Danbooru API */
    danbooru : {
      /** Danbooru username */
      username : string
      /** Danbooru API key */
      apiKey : string
    }
    /** Tumblr client key */
    tumblr : string
    /** osu! API key */
    osu : string
  }
  /** Miscellaneous settings */
  misc : {
    /** Message to show in the help command */
    helpMessage : string
  }
}


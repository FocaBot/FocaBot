import fs from 'mz/fs'
import path from 'path'
import yaml from 'js-yaml'
import { FocaBotConfig } from '../focabot-config'

export { default as printHeader, version, versionName } from '../header'

/**
 * Location of the current user's home path.
 */
export const homePath = process.env[process.platform === 'win32' ? 'USERPROFILE' : 'HOME'] || ''
/**
 * Location of the default data directory.
 */
export let dataPath = path.join(homePath, '.focaBot')
// Snap Support
if (process.env.SNAP_USER_DATA) {
  dataPath = process.env.SNAP_USER_DATA
}
/**
 * Default location of the config file.
 */
export const configPath = process.env.FOCABOT_CONFIG || path.join(dataPath, 'config.yml')

/**
 * Checks if the data path exists and creates it if it doesn't.
 */
export async function ensureDataPath () {
  if (await fs.exists(dataPath)) return
  await fs.mkdir(dataPath)
}

/**
 * Get the default configuration
 */
export async function getDefaultConfig () : Promise<FocaBotConfig> {
  const defaultConfigPath = path.join(__dirname, '..', '..', 'focabot.example.yml')
  // Use example config as base
  const config = yaml.safeLoad(await fs.readFile(defaultConfigPath, 'utf8')) as FocaBotConfig
  // Alter some parameters
  config.bot.token = ''
  config.bot.globalAdmins = []
  config.bot.owners = []
  config.data.backend = 'gun'
  config.data.gun.path = dataPath
  return config
}

/**
 * Loads a configuration file.
 * @param path - Path of the config file to load. Defaults to the global config.
 * @param fallbackToDefault - Fallback to default config if the file is not present.
 */
export async function loadConfig (path = configPath, fallbackToDefault = false) : Promise<FocaBotConfig> {
  if (await fs.exists(path)) {
    return yaml.safeLoad(await fs.readFile(path, 'utf8')) as FocaBotConfig
  } else if (fallbackToDefault) {
    return getDefaultConfig()
  } else {
    throw new Error("Couldn't find config file.")
  }
}

/**
 * Saves a configuration file.
 * @param config - Config to save
 * @param path - Config file path
 */
export async function saveConfig (config : FocaBotConfig, path = configPath) {
  if (path.indexOf(dataPath) >= 0) await ensureDataPath()
  const configRaw = yaml.safeDump(config)
  await fs.writeFile(path, configRaw, 'utf8')
  return
}

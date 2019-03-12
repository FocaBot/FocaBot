import { version, versionName } from './common'
import { StartAction, ConfigAction, ReconfigureAction } from './actions'
import cli, { Command } from 'commander'

cli
  .name('focabot')
  .version(`${version} (${versionName})`, '-v, --version')
  .arguments('[action]')
  .description(`Possible actions:
  start - Start FocaBot
  config - Edit configuration
  reconfigure - Perform initial setup`)
  .option('-c, --config [focabot.yml]', 'specify a configuration file to use')
  .option('-d, --debug', 'enable verbose logging')
  .option('-S, --no-sharding', 'disable sharding (force single-process mode)')
  .action((action : string, ctx : Command) => {
    switch ((action || '').toLowerCase()) {
      case 'config':
        ConfigAction(ctx).catch(e => console.error(e))
        break
      case 'reconfigure':
        ReconfigureAction(ctx).catch(e => console.error(e))
        break
      default:
        StartAction(ctx).catch(e => console.error(e))
    }
  })
  .parse(process.argv)

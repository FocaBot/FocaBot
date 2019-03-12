import { Command } from 'commander'

export async function ConfigAction (ctx : ConfigActionContext) {
  console.log('To be implemented')
}

interface ConfigActionContext extends Command {
  config ?: string
}

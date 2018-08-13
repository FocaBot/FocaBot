#set($CLASS = ${StringUtils.capitalizeFirstLetter(${NAME})})
#parse("Module Header.js")
import { Azarasi } from 'azarasi'

export default class ${CLASS} extends Azarasi.Module {
  init () {
    
  }
}

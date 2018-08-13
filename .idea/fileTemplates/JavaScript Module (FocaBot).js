#set($CLASS = ${StringUtils.capitalizeFirstLetter(${NAME})})
#parse("Module Header.js")
const { Azarasi } = require('azarasi')

class ${CLASS} extends Azarasi.Module {
  init () {
    
  }
}

module.exports = ${CLASS}

#set($CLASS = ${StringUtils.capitalizeFirstLetter(${NAME})})
###
${CLASS} Module
@author ${NAME}
@license MIT
###
{ Azarasi } = require 'azarasi'

class ${CLASS} extends Azarasi.Module
  init: ->
    
module.exports = ${CLASS}
module.exports = (filter, param)=>
  BaseFilter = require "./#{filter}"
  return class Filter extends BaseFilter
    constructor: (p, member, playing, filters)-> super(param, member, playing, filters)
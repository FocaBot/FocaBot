class AudioFilterPreset
  constructor: (originalFilter, @param)->
    @original = new originalFilter @param
    @validate = @original.validate
    @toFFMPEGFilter = @original.toFFMPEGFilter
    @toString = @original.toString
    @isAdminOnly = @original.isAdminOnly
    @processTime = @original.processTime

module.exports = AudioFilterPreset

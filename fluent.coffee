# Fluent

{ PromiseKeeper } = require 'promise-keeper'
{ Deferred } = require 'promise.coffee'

createPage = (options) ->
  (new PromiseKeeper())
  .useAll require './decorators/debugging'
  .useAll require './decorators/filesystem'
  #.useAll require './decorators/time'
  #.useAll require './decorators/phantom'
  #.createPhantom(options)
  #.createPage()

module.exports = createPage

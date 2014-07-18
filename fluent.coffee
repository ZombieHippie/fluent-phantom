# Fluent

{ PromiseKeeper } = require 'promise-keeper'
{ Deferred } = require 'promise.coffee'

create = (options) ->
  (new PromiseKeeper())
  .extend require './decorators/debugging'
  .extend require './decorators/filesystem'
  .extend require './decorators/timer'
  .extend require './decorators/phantom'
  .createPhantom(options)
module.exports = create

# Debugging decorators
{ Deferred } = require 'promise.coffee'

module.exports =
  # .log() outputs current value
  # .log(String message) outputs message
  # Resolves to original value
  log: (message) ->
    @then (value) =>
      def = new Deferred
      if message?
        console.log message
      else
        console.log value
      def.resolve value
      def.promise

  # .observe(Function fn) allows you to manipulate the current value synchronously with a function
  # Resolves to return from fn(originalValue)
  observe: (fn) ->
    if typeof fn isnt "function"
      throw TypeError(".observe(Function fn) requires a function parameter")
    @then (value) =>
      def = new Deferred
      # Resolves to return value of fn
      def.resolve fn value
      def.promise

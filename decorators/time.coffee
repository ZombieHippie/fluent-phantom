# Debugging decorators
{ Deferred } = require 'promise.coffee'

module.exports =
  # .startTimer() records the current time under originalValue
  # .startTimer(String label) records the current time under label
  # Resolves to original value
  startTimer: (label) ->
    @datatime ?= {}
    if label?
      if typeof label isnt "string"
        throw TypeError(".startTimer(String label) requires label to be a String")
      else
        return @then (value) =>
          @datatime[label] = Date.now()
          value
    else
      return @then (value) =>
          @datatime[value] = Date.now()
          value
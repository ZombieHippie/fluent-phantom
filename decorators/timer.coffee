# Debugging decorators
{ Deferred } = require 'promise.coffee'

module.exports =
  # .startTimer() records the current time under originalValue
  # .startTimer(String label) records the current time under label
  # Resolves to original value
  startTimer: (label) ->
    @datatimer ?= {}
    if label?
      if typeof label isnt "string"
        throw TypeError(".startTimer(String label) requires label to be a String")
      else
        return @then (value) =>
          @datatimer[label] = Date.now()
          value
    else
      return @then (value) =>
        @datatimer[value] = Date.now()
        value
  # .stopTimer() deletes the time under originalValue
  # .stopTimer(String label) deletes the time under label
  # Resolves to difference between now and recorded time in milliseconds
  stopTimer: (label) ->
    @datatimer ?= {}
    if label?
      if typeof label isnt "string"
        throw TypeError(".stopTimer(String label) requires label to be a String")
      else
        return @then =>
          prevTime = @datatimer[label]
          delete @datatimer[label]
          Date.now() - prevTime
    else
      return @then (value) =>
        prevTime = @datatimer[value]
        delete @datatimer[value]
        Date.now() - prevTime
  # .getTimer() uses the time under originalValue
  # .getTimer(String label) uses the time under label
  # Resolves to difference between now and recorded time in milliseconds
  getTimer: (label) ->
    @datatimer ?= {}
    if label?
      if typeof label isnt "string"
        throw TypeError(".getTimer(String label) requires label to be a String")
      else
        return @then =>
          prevTime = @datatimer[label]
          Date.now() - prevTime
    else
      return @then (value) =>
        prevTime = @datatimer[value]
        Date.now() - prevTime

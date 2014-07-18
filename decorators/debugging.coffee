# Debugging decorators

module.exports =
  # .log() outputs current value
  # .log(String message) outputs formatted message replacing '%s' with original value
  # .log(Function message) outputs message(value)
  # Resolves to original value
  log: (message) ->
    @then (value) =>
      message ?= value
      if typeof message is "string"
        console.log message.replace("%s", String(value))
      else if typeof message is "function"
        console.log message(value)
      else
        console.log message
      value
  # .alter(Function fn) allows you to manipulate the current value synchronously with a function
  # Resolves to return from fn(originalValue)
  alter: (fn) ->
    if typeof fn isnt "function"
      throw TypeError(".alter(Function fn) requires a function parameter")
    @then (value) =>
      # Resolves to return value of fn
      fn value
  # .assert(Object value) Error if original value does not equal value
  # .assert(Object value, String message) Error with message if original value does not equal value
  # Resolves to original value, or rejects to original value
  assert: (value, message) ->
    if message?
      if typeof message isnt "string"
        throw TypeError(".assert(Object value, String message) requires message to be of type String")
    @then (originalValue) ->
      if originalValue isnt value
        if message?
          throw Error(message)
        else
          throw Error(originalValue)
  else: (fn) ->
    @then(null, fn)
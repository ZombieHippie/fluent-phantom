# Debugging decorators

module.exports =
  # .log() outputs current value
  # .log(String message) outputs message
  # .log(Function message) outputs message(value)
  # Resolves to original value
  log: (message) ->
    @then (value) =>
      if message?
        if typeof message is "string"
          console.log message.replace("%s", String(value))
        else if typeof message is "function"
          console.log message(value)
        else
          throw TypeError(".log(String message) requires message to be a String or Function")
      else
        console.log value
      value
  # .alter(Function fn) allows you to manipulate the current value synchronously with a function
  # Resolves to return from fn(originalValue)
  alter: (fn) ->
    if typeof fn isnt "function"
      throw TypeError(".alter(Function fn) requires a function parameter")
    @then (value) =>
      # Resolves to return value of fn
      fn value

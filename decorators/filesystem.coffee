# Debugging decorators
{ Deferred } = require 'promise.coffee'
nodeStyleLift = require('when/node').lift
fs = require 'fs'

readAsync = nodeStyleLift fs.readFile
writeAsync = nodeStyleLift fs.writeFile

module.exports =
  # .read() read from file at originalValue
  # .read(String path) read file from path
  # Resolves to a String of file's content
  read: (path) ->
    if path?
      if typeof path isnt "string"
        throw TypeError ".read(String path) path needs to be a String"
      else
        return @then ->
          readAsync(path, "utf8")
    else
      return @then (value) ->
        readAsync(value, "utf8")

  # .write(String path) write originalValue to file at path
  # .write(null, String content) write content to file at originalValue
  # .write(String path, String content) write content to file at path
  # Resolves to a String of file's content
  write: (path, content) ->
    if path? and not content?
      if typeof path isnt "string"
        throw TypeError ".write(String path) path needs to be a String"
      else
        return @then (value) ->
          writeAsync(path, value)
    else if not path? and content?
      if typeof content isnt "string"
        throw TypeError ".write(null, String content) content needs to be a String"
      else if path isnt null
        throw TypeError ".write(String path, String content) path cannot be undefined"
      else
        return @then (value) ->
          writeAsync(value, content)
    else if path? and content?
      if typeof path isnt "string"
        throw TypeError ".write(String path, String content) path needs to be a String"
      else if typeof content isnt "string"
        throw TypeError ".write(String path, String content) content needs to be a String"
      else
        return @then ->
          writeAsync(path, content)
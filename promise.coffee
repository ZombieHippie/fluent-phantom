# Promises

# Use Request from index
{ Request } = require './'
fs = require 'fs'
When = require 'when'
Callbacks = require 'when/callbacks'
Nodefn = require 'when/node'

Say = (data) ->
  if typeof data is 'function'
    data = data.toString()
  console.log data
print = (title) ->
  When.lift (data) ->
      console.log("<#{title}>")
      if typeof data is 'function'
        data = data.toString()
      console.log data
      return "Printed"

class FileOp
  constructor: ->
    @promise = (When.lift (->"no data"))()
  read: (path) ->
    @promise = (Nodefn.liftCallback fs.readFile)(path, "utf8")
    @
  then: (a, b) ->
    print("a")(a.toString())
    @promise = @promise.then a, b
    @
  print: () ->
    @then print("data")
  catch: (fn) ->
    @promise = @promise.catch fn
    @
  write: (path) ->
    print("path")(path)
    @then (content) ->
      print("content")(content)
      (Nodefn.liftCallback fs.writeFile)(path, content)

(new FileOp()).read('package.json').write('package2.json').catch(print("r/w error"))
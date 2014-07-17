# Fluent Test

Fluent = require './fluent'

Fluent()
.read('package.json')
.log('<package.json>')
.log()
.observe (value) ->
  typeof value
.log('typeof package.json:')
.log()